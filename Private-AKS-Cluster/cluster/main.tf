resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
  tags     = var.tags
}