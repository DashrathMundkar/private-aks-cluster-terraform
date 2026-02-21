resource "azurerm_virtual_network" "virtual_network" {
  depends_on          = [azurerm_resource_group.rg1]
  name                = var.azurerm_virtual_network
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.aks_vnet_address_prefix]
  #dns_servers = ["209.244.0.3", "209.244.0.4"]

  tags = {
    environment = "${var.tags.env}"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  depends_on           = [azurerm_virtual_network.virtual_network]
  name                 = "aks-subnet"
  address_prefixes     = [var.aks_subnet_address_prefix]
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  service_endpoints    = ["Microsoft.Storage"]
}

data "azurerm_virtual_network" "firewall_virtual_network" {
  name                = "firewall-vnet"
  resource_group_name = "firewall-rg"
}

resource "azurerm_virtual_network_peering" "aks_to_firewall" {
  name                         = "aks-to-firewall"
  resource_group_name          = var.rgname
  virtual_network_name         = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id    = data.azurerm_virtual_network.firewall_virtual_network.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}