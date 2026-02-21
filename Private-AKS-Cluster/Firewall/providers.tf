terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.28.0"
    }
  }
  required_version = ">= 1.8.3"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
  }
}