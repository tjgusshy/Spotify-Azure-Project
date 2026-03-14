terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Optional: store state remotely in ADLS Gen2 to avoid local state file risk.
  # Uncomment and fill in once the storage account is imported/managed.
  # backend "azurerm" {
  #   resource_group_name  = "<your-resource-group>"
  #   storage_account_name = "sptfsgproject"
  #   container_name       = "tfstate"
  #   key                  = "spotify-project.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
