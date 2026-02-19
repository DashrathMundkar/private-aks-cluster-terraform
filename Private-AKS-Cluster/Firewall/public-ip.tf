resource "azurerm_public_ip" "firewall_public_ip" {
  name                = "${var.firewall_name}-public-ip"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"  
}