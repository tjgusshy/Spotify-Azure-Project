# ── Azure Data Factory ────────────────────────────────────────────────────────
resource "azurerm_data_factory" "main" {
  name                = "sptfdatafactory"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ── Linked Service: Azure SQL Database ───────────────────────────────────────
# Uses SQL authentication. The connection string is built from your variables.
# After import, Terraform will update the linked service to use this connection
# string (replacing the ADF-internal encrypted credential).
resource "azurerm_data_factory_linked_service_azure_sql_database" "azure_sql" {
  name            = "azure_sql"
  data_factory_id = azurerm_data_factory.main.id

  connection_string = "Server=tcp:azprojectsptf.database.windows.net,1433;Initial Catalog=sptfDb;Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

# ── Linked Service: ADLS Gen2 ────────────────────────────────────────────────
# Uses Account Key auth — matching the existing ADF configuration.
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "datalake" {
  name                = "datalake"
  data_factory_id     = azurerm_data_factory.main.id
  url                 = "https://sptfsgproject.dfs.core.windows.net/"
  storage_account_key = var.storage_account_key
}

# ── Dataset: AZURE_SQL ────────────────────────────────────────────────────────
resource "azurerm_data_factory_custom_dataset" "AZURE_SQL" {
  name            = "AZURE_SQL"
  data_factory_id = azurerm_data_factory.main.id
  type            = "AzureSqlTable"

  linked_service {
    name = azurerm_data_factory_linked_service_azure_sql_database.azure_sql.name
  }

  type_properties_json = jsonencode({})
  schema_json          = jsonencode([])
  annotations          = []
}

# ── Dataset: AzureSqlTable1 ───────────────────────────────────────────────────
resource "azurerm_data_factory_custom_dataset" "AzureSqlTable1" {
  name            = "AzureSqlTable1"
  data_factory_id = azurerm_data_factory.main.id
  type            = "AzureSqlTable"

  linked_service {
    name = azurerm_data_factory_linked_service_azure_sql_database.azure_sql.name
  }

  type_properties_json = jsonencode({})
  schema_json          = jsonencode([])
  annotations          = []
}

# ── Dataset: Json_dynamic ─────────────────────────────────────────────────────
# Parameterised JSON dataset — container/folder/file are passed at runtime.
resource "azurerm_data_factory_custom_dataset" "Json_dynamic" {
  name            = "Json_dynamic"
  data_factory_id = azurerm_data_factory.main.id
  type            = "Json"

  linked_service {
    name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake.name
  }

  parameters = {
    container = "String"
    folder    = "String"
    file      = "String"
  }

  type_properties_json = jsonencode({
    location = {
      type       = "AzureBlobFSLocation"
      fileName   = { value = "@dataset().file", type = "Expression" }
      folderPath = { value = "@dataset().folder", type = "Expression" }
      fileSystem = { value = "@dataset().container", type = "Expression" }
    }
  })

  schema_json = jsonencode({})
  annotations = []
}

# ── Dataset: Json1 ────────────────────────────────────────────────────────────
# Parameterised JSON dataset — same structure as Json_dynamic.
resource "azurerm_data_factory_custom_dataset" "Json1" {
  name            = "Json1"
  data_factory_id = azurerm_data_factory.main.id
  type            = "Json"

  linked_service {
    name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake.name
  }

  parameters = {
    container = "String"
    folder    = "String"
    file      = "String"
  }

  type_properties_json = jsonencode({
    location = {
      type       = "AzureBlobFSLocation"
      fileName   = { value = "@dataset().file", type = "Expression" }
      folderPath = { value = "@dataset().folder", type = "Expression" }
      fileSystem = { value = "@dataset().container", type = "Expression" }
    }
  })

  schema_json = jsonencode({})
  annotations = []
}

# ── Dataset: parquet_dynamic ──────────────────────────────────────────────────
# Parameterised Parquet dataset with Snappy compression.
resource "azurerm_data_factory_custom_dataset" "parquet_dynamic" {
  name            = "parquet_dynamic"
  data_factory_id = azurerm_data_factory.main.id
  type            = "Parquet"

  linked_service {
    name = azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake.name
  }

  parameters = {
    container = "String"
    folder    = "String"
    file      = "String"
  }

  type_properties_json = jsonencode({
    location = {
      type       = "AzureBlobFSLocation"
      fileName   = { value = "@dataset().file", type = "Expression" }
      folderPath = { value = "@dataset().folder", type = "Expression" }
      fileSystem = { value = "@dataset().container", type = "Expression" }
    }
    compressionCodec = "snappy"
  })

  schema_json = jsonencode([])
  annotations = []
}

# ── Pipeline: incremental ─────────────────────────────────────────────────────
# Activities are read directly from the existing pipeline JSON file so this file
# stays in sync with what you already have in ADF.
# lifecycle.ignore_changes means pipeline edits made in the ADF UI are not
# overwritten on the next `terraform apply`. Remove it if you want Terraform to
# be the single source of truth for pipeline definitions.
resource "azurerm_data_factory_pipeline" "incremental" {
  name            = "incremental"
  data_factory_id = azurerm_data_factory.main.id

  activities_json = jsonencode(
    jsondecode(file("${path.module}/../pipeline/incremental.json")).properties.activities
  )

  # Parameter types — default values are managed inside the JSON file above.
  parameters = {
    loop_input = "Array"
  }

  variables = {
    current = "String"
  }

  annotations = []

  lifecycle {
    ignore_changes = [activities_json]
  }

  depends_on = [
    azurerm_data_factory_custom_dataset.AZURE_SQL,
    azurerm_data_factory_custom_dataset.Json1,
    azurerm_data_factory_custom_dataset.Json_dynamic,
    azurerm_data_factory_custom_dataset.parquet_dynamic,
  ]
}

# ── Pipeline: lookup ──────────────────────────────────────────────────────────
resource "azurerm_data_factory_pipeline" "lookup" {
  name            = "lookup"
  data_factory_id = azurerm_data_factory.main.id

  activities_json = jsonencode(
    jsondecode(file("${path.module}/../pipeline/lookup.json")).properties.activities
  )

  parameters = {
    schema    = "String"
    table     = "String"
    cdc_col   = "String"
    from_date = "String"
  }

  variables = {
    current = "String"
  }

  annotations = []

  lifecycle {
    ignore_changes = [activities_json]
  }

  depends_on = [
    azurerm_data_factory_custom_dataset.AZURE_SQL,
    azurerm_data_factory_custom_dataset.Json1,
    azurerm_data_factory_custom_dataset.Json_dynamic,
    azurerm_data_factory_custom_dataset.parquet_dynamic,
  ]
}
