resource "azurerm_resource_group" "firewall_rg" {
  name     = var.resource_group_name
  location = var.location
}