# ── Resource Group ────────────────────────────────────────────────────────────
# Import command is in import.ps1. Terraform will manage — but NOT delete —
# the resource group as long as other resources still live inside it.
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Azure SQL Server ──────────────────────────────────────────────────────────
# Cost tip: the server itself is free; cost comes from the database SKU below.
resource "azurerm_mssql_server" "main" {
  name                         = "azprojectsptf"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  # Prevent public access except to Azure services and your IP rule below.
  public_network_access_enabled = true

  tags = var.tags
}

# Allow Azure-internal traffic (required by ADF to reach the database).
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Azure SQL Database ────────────────────────────────────────────────────────
# Cost tip: change sql_sku to "Basic" to drop to ~$5/month when not actively
# loading data. Change back to "S0" or higher before running pipelines.
resource "azurerm_mssql_database" "spotify" {
  name      = "sptfDb"
  server_id = azurerm_mssql_server.main.id
  sku_name  = var.sql_sku

  tags = var.tags
}

# ── ADLS Gen2 Storage Account ─────────────────────────────────────────────────
# is_hns_enabled = true enables the hierarchical namespace required for ADLS Gen2.
# LRS replication is the cheapest option and sufficient for a personal project.
resource "azurerm_storage_account" "datalake" {
  name                     = "sptfsgproject"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# ── ADLS Gen2 Filesystem: bronze ──────────────────────────────────────────────
# The 'bronze' container (filesystem) used by all ADF pipelines as the raw
# landing zone. Requires the storage account's hierarchical namespace (HNS).
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.datalake.id
}

# ── Databricks Access Connector ───────────────────────────────────────────────
# Managed identity used by the Databricks workspace to access ADLS Gen2
# without needing storage account keys.
resource "azurerm_databricks_access_connector" "main" {
  name                = "sptfaccessconnector"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ── Azure Databricks Workspace ────────────────────────────────────────────────
# Standard tier is sufficient for personal/dev projects.
# Premium tier is required if you need Unity Catalog, SCIM, or Azure AD
# Conditional Access integration.
resource "azurerm_databricks_workspace" "main" {
  name                = "sptfdb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "premium"

  tags = var.tags
}
