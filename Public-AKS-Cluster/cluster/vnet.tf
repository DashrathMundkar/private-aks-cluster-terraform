resource "azurerm_virtual_network" "virtual_network" {
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
