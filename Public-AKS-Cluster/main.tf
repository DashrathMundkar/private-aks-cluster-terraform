resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
  tags = var.tags
}

module "cluster" {
  depends_on              = [ azurerm_resource_group.rg1 ]
  source                  = "./cluster"
  location                = var.location
  security_group          = var.security_group
  azurerm_virtual_network = var.azurerm_virtual_network
  rgname                  = var.rgname
  kubernetes_version      = var.kubernetes_version
  azurerm_lb              = var.azurerm_lb
  publicip                = var.publicip
  tags                    = var.tags 
  location_short_name = var.location_short_name
  subscription_id = var.subscription_id
}