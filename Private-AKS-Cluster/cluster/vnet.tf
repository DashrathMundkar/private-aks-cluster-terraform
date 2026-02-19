resource "azurerm_virtual_network" "virtual_network" {
  depends_on = [ azurerm_resource_group.rg1 ]
  name                = var.azurerm_virtual_network
  location            = var.location
  resource_group_name = var.rgname
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "${var.tags.env}"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  depends_on            = [ azurerm_virtual_network.virtual_network ]
  name                  = "aks-subnet"
  address_prefixes      = ["10.0.1.0/24"]
  resource_group_name   = var.rgname
  virtual_network_name  = azurerm_virtual_network.virtual_network.name  
}

/*data "azurerm_virtual_network" "firewall_virtual_network" {
  name                = "firewall-vnet"
  resource_group_name = "firewall-rg"
}
resource "azurerm_virtual_network_peering" "aks_to_firewall" {
  name                      = "aks-to-firewall"
  resource_group_name       = var.rgname
  virtual_network_name      = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id = data.azurerm_virtual_network.firewall_virtual_network.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}*/

