terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.53.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.38.0"
    }
  }

  required_version = ">= 1.8.3"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
  