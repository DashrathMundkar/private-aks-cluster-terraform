provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

/*resource "azurerm_resource_group" "rg2" {
  name     = "resource-group2"
  location = "West Europe"
}*/

module "cluster" {
  depends_on = [ azurerm_resource_group.rg1 ]
  source = "cluster"
  location = var.location
  security_group = var.security_group
  azurerm_virtual_network = var.azurerm_virtual_network
  rgname = var.rgname
  kubernetes_version = var.kubernetes_version
  azurerm_lb = var.azurerm_lb
  publicip = var.publicip
}