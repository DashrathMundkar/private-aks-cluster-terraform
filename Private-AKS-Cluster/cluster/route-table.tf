data "azurerm_public_ip" "firewall_public_ip" {
  name                = "aks-firewall-public-ip"
  resource_group_name = "firewall-rg"
}

resource "azurerm_route_table" "dev_route_table" {
  depends_on = [ azurerm_resource_group.rg1 ]
  name                = "dev-route-table"
  resource_group_name = var.rgname
  location            = var.location
  tags                = var.tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_route_table_association" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.dev_route_table.id
}
