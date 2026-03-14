# ============================================================================
# import.ps1 — Import manually-created Azure resources into Terraform state
# ============================================================================
# Prerequisites:
#   1. Install Terraform >= 1.5  : https://developer.hashicorp.com/terraform/install
#   2. Install Azure CLI         : winget install Microsoft.AzureCLI
#   3. Log in                    : az login
#   4. Copy terraform.tfvars.example -> terraform.tfvars and fill in values
#   5. Run from the terraform/ directory:  cd terraform ; .\import.ps1
# ============================================================================

# ---------- CONFIGURE THESE TWO VALUES --------------------------------------
$SUBSCRIPTION_ID    = "5ca58f46-7497-4c6c-bed2-c636bac45a03"
$RESOURCE_GROUP     = "spotifyprojectRG"
# ----------------------------------------------------------------------------

$ADF_NAME     = "sptfdatafactory"
$SQL_SERVER   = "azprojectsptf"
$SQL_DB       = "sptfDb"
$STORAGE      = "sptfsgproject"
$SUB          = "/subscriptions/$SUBSCRIPTION_ID"
$RG           = "$SUB/resourceGroups/$RESOURCE_GROUP"

Write-Host "`n==> terraform init" -ForegroundColor Cyan
terraform init

Write-Host "`n==> Importing Resource Group" -ForegroundColor Cyan
terraform import azurerm_resource_group.main `
    "$RG"

Write-Host "`n==> Importing SQL Server" -ForegroundColor Cyan
terraform import azurerm_mssql_server.main `
    "$RG/providers/Microsoft.Sql/servers/$SQL_SERVER"

Write-Host "`n==> Importing SQL Database" -ForegroundColor Cyan
terraform import azurerm_mssql_database.spotify `
    "$RG/providers/Microsoft.Sql/servers/$SQL_SERVER/databases/$SQL_DB"

Write-Host "`n==> Importing SQL Firewall Rule (AllowAzureServices)" -ForegroundColor Cyan
terraform import azurerm_mssql_firewall_rule.allow_azure_services `
    "$RG/providers/Microsoft.Sql/servers/$SQL_SERVER/firewallRules/AllowAzureServices"

Write-Host "`n==> Importing Storage Account (ADLS Gen2)" -ForegroundColor Cyan
terraform import azurerm_storage_account.datalake `
    "$RG/providers/Microsoft.Storage/storageAccounts/$STORAGE"

Write-Host "`n==> Importing ADLS Gen2 Filesystem: bronze" -ForegroundColor Cyan
terraform import azurerm_storage_data_lake_gen2_filesystem.bronze `
    "https://$STORAGE.dfs.core.windows.net/bronze"

Write-Host "`n==> Importing Databricks Access Connector" -ForegroundColor Cyan
terraform import azurerm_databricks_access_connector.main `
    "$RG/providers/Microsoft.Databricks/accessConnectors/sptfaccessconnector"

Write-Host "`n==> Importing Databricks Workspace" -ForegroundColor Cyan
terraform import azurerm_databricks_workspace.main `
    "$RG/providers/Microsoft.Databricks/workspaces/sptfdb"

Write-Host "`n==> Importing Azure Data Factory" -ForegroundColor Cyan
terraform import azurerm_data_factory.main `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME"

Write-Host "`n==> Importing Linked Service: azure_sql" -ForegroundColor Cyan
terraform import azurerm_data_factory_linked_service_azure_sql_database.azure_sql `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/linkedservices/azure_sql"

Write-Host "`n==> Importing Linked Service: datalake" -ForegroundColor Cyan
terraform import azurerm_data_factory_linked_service_data_lake_storage_gen2.datalake `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/linkedservices/datalake"

Write-Host "`n==> Importing Dataset: AZURE_SQL" -ForegroundColor Cyan
terraform import azurerm_data_factory_custom_dataset.AZURE_SQL `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/datasets/AZURE_SQL"

Write-Host "`n==> Importing Dataset: AzureSqlTable1" -ForegroundColor Cyan
terraform import azurerm_data_factory_custom_dataset.AzureSqlTable1 `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/datasets/AzureSqlTable1"

Write-Host "`n==> Importing Dataset: Json_dynamic" -ForegroundColor Cyan
terraform import azurerm_data_factory_custom_dataset.Json_dynamic `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/datasets/Json_dynamic"

Write-Host "`n==> Importing Dataset: Json1" -ForegroundColor Cyan
terraform import azurerm_data_factory_custom_dataset.Json1 `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/datasets/Json1"

Write-Host "`n==> Importing Dataset: parquet_dynamic" -ForegroundColor Cyan
terraform import azurerm_data_factory_custom_dataset.parquet_dynamic `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/datasets/parquet_dynamic"

Write-Host "`n==> Importing Pipeline: incremental" -ForegroundColor Cyan
terraform import azurerm_data_factory_pipeline.incremental `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/pipelines/incremental"

Write-Host "`n==> Importing Pipeline: lookup" -ForegroundColor Cyan
terraform import azurerm_data_factory_pipeline.lookup `
    "$RG/providers/Microsoft.DataFactory/factories/$ADF_NAME/pipelines/lookup"

Write-Host "`n==> All imports complete. Running plan to check for drift..." -ForegroundColor Green
Write-Host "    Expected changes after import:" -ForegroundColor Yellow
Write-Host "    - azure_sql linked service: connection string updated (encrypted cred replaced)" -ForegroundColor Yellow
Write-Host "    - datalake linked service: account key updated" -ForegroundColor Yellow
Write-Host "    - resource tags: added if not already present" -ForegroundColor Yellow
Write-Host ""
terraform plan
