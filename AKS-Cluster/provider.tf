terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "~>3.0"
    }
  }
  /*backend "azurerm" {                          # We need to migrate this and can only be useful after the storage account and container creation
    resource_group_name  = "terraform-test"
    storage_account_name = "dashrath"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }*/
}


/*resource "azurerm_storage_account" "tfstate" {
  depends_on = [ 
    azurerm_resource_group.rg1 
  ]
  name                     = var.storage_account_name
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  depends_on = [
    azurerm_storage_account.tfstate
  ]
  name                  = var.azurerm_storage_container
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}*/
