data "azurerm_firewall" "aks_firewall" {
  name                = "aks-firewall"
  resource_group_name = "firewall-rg"
}

resource "azurerm_route_table" "dev_route_table" {
  depends_on          = [azurerm_virtual_network.virtual_network]
  name                = "dev-route-table"
  resource_group_name = var.rgname
  location            = var.location
  tags                = var.tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_firewall.aks_firewall.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_route_table_association" {
  depends_on     = [azurerm_route_table.dev_route_table]
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.dev_route_table.id
}
