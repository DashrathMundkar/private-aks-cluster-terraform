resource "azurerm_route_table" "firewall_route_table" {
  name                = "firewall-route-table"
  resource_group_name = var.rgname
  location            = var.location    
  tags                = var.tags

  route = [ {  
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  } ]

}

resource "azurerm_subnet_route_table_association" "aks_subnet_route_table_association" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.firewall_route_table.id  
}