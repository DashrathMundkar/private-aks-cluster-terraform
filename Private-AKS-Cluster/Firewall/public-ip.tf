resource "azurerm_public_ip" "firewall_public_ip" {
  name                = "${var.firewall_name}-public-ip"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"  
}

/*resource "azurerm_public_ip" "nat_gateway_public_ip" {
  name                = "${var.nat_gateway_name}-public-ip"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"   
}*/

resource "azurerm_public_ip" "ip-dev-1" {
  name                = "dev-1-public-ip"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"  
}