output "data_factory_id" {
  description = "Resource ID of the Azure Data Factory."
  value       = azurerm_data_factory.main.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "storage_dfs_endpoint" {
  description = "Primary DFS (ADLS Gen2) endpoint for the storage account."
  value       = azurerm_storage_account.datalake.primary_dfs_endpoint
}

output "resource_group_id" {
  description = "Resource ID of the resource group."
  value       = azurerm_resource_group.main.id
}

output "databricks_workspace_url" {
  description = "URL of the Azure Databricks workspace."
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "databricks_access_connector_id" {
  description = "Resource ID of the Databricks Access Connector (managed identity)."
  value       = azurerm_databricks_access_connector.main.id
}
