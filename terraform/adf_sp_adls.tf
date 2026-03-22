## Managed Identity: Assign Storage Blob Data Contributor to ADF's managed identity
resource "azurerm_role_assignment" "adf_adls_blob_contrib" {
  scope                = azurerm_storage_account.datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id
}
