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

resource "azurerm_subnet" "pep" {
  name                 = "pep-subnet"
  resource_group_name  = azurerm_resource_group.firewall_rg.name
  virtual_network_name = azurerm_virtual_network.firewall_vnet.name
  address_prefixes     = ["172.16.2.0/24"]
  private_endpoint_network_policies         = "Enabled"
  
}

data "azurerm_virtual_network" "aks_virtual_network" {
  name                = "dev-core-vnet"
  resource_group_name = "dev-core"
}
resource "azurerm_virtual_network_peering" "firewall_to_aks" {
  name                      = "firewall-to-aks"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  virtual_network_name      = azurerm_virtual_network.firewall_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.aks_virtual_network.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}