resource "azurerm_virtual_network" "firewall_vnet" {
  name                = var.firewall_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.firewall_rg.name
  address_space       = ["172.16.0.0/12"]

  tags = {
    environment = "${var.tags}"
  }
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name
  resource_group_name  = azurerm_resource_group.firewall_rg.name
  virtual_network_name = azurerm_virtual_network.firewall_vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

/*resource "azurerm_nat_gateway" "firewall_nat_gateway" {
  name                = "${var.firewall_name}-nat-gateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.firewall_rg.name
  sku                 = "Standard" 
}

resource "azurerm_nat_gateway_public_ip_association" "nat_public_ip_association"{
  nat_gateway_id = azurerm_nat_gateway.firewall_nat_gateway.id
  public_ip_address_id   = azurerm_public_ip.nat_gateway_public_ip.id   
}*/