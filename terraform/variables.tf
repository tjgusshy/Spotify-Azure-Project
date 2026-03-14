variable "subscription_id" {
  description = "Your Azure Subscription ID. Find it in the Azure Portal under Subscriptions."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group that contains all Spotify project resources."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "uksouth"
}

variable "sql_admin_username" {
  description = "SQL Server administrator login — matches the 'userName' in the azure_sql linked service."
  type        = string
  default     = "teejay"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password. Never commit this value — use a tfvars file or environment variable TF_VAR_sql_admin_password."
  type        = string
  sensitive   = true
}

variable "sql_sku" {
  description = "DTU-based SKU for the Azure SQL Database. Use 'Basic' (~$5/mo, 5 DTUs) or 'S0' (~$15/mo, 10 DTUs) for a personal project."
  type        = string
  default     = "S0"
}

variable "storage_account_key" {
  description = "Primary access key for the sptfsgproject storage account. Find it in Azure Portal > Storage Account > Access keys. Never commit this value."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to every managed resource — useful for cost filtering in Azure Cost Management."
  type        = map(string)
  default = {
    project     = "spotify-azure"
    environment = "personal"
    managed_by  = "terraform"
  }
}
