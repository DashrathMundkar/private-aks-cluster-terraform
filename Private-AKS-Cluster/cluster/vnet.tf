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

resource "azurerm_subnet" "ingress_subnet" {
  depends_on            = [ azurerm_virtual_network.virtual_network ]
  name                  = "ingress-subnet"
  address_prefixes      = ["10.0.2.0/24"]
  resource_group_name   = var.rgname
  virtual_network_name  = azurerm_virtual_network.virtual_network.name  
  private_link_service_network_policies_enabled = false 
}

resource "azurerm_subnet" "internal_subnet" {
  depends_on            = [ azurerm_virtual_network.virtual_network ]
  name                  = "internal-subnet"
  address_prefixes      = ["10.0.3.0/24"]
  resource_group_name   = var.rgname
  virtual_network_name  = azurerm_virtual_network.virtual_network.name  
  private_link_service_network_policies_enabled = false 
}

resource "azurerm_subnet" "psql" {
  name                                          = "snet-psql-${var.tags.env}-${var.location_short_name}-001"
  virtual_network_name                          = azurerm_virtual_network.virtual_network.name
  resource_group_name                           = var.rgname
  address_prefixes                              = ["10.0.4.0/24"] # 1024 possible hosts
  service_endpoints                             = ["Microsoft.Storage"]
  private_endpoint_network_policies             = "Disabled" # To deploy private link service
  private_link_service_network_policies_enabled = false # To deploy private link service

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "azure_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.5.0/26"]
}