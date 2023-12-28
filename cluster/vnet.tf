resource "azurerm_virtual_network" "virtual_network" {
  name                = var.azurerm_virtual_network
  location            = var.location
  resource_group_name = var.rgname
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "staging"
  }
}

resource "azurerm_subnet" "subnet1" {
  depends_on = [ azurerm_virtual_network.virtual_network ]
  name             = "subnet1"
  address_prefixes = ["10.1.0.0/24"]
  resource_group_name = var.rgname
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_virtual_network" "virtual_network_new" {
  name                = "new-vnet"
  location            = "West Europe"
  resource_group_name = "resource-group2"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_new" {
  depends_on = [ azurerm_virtual_network.virtual_network ]
  name             = "subnet1"
  address_prefixes = ["10.0.0.0/24"]
  resource_group_name = "resource-group2"
  virtual_network_name = azurerm_virtual_network.virtual_network_new.name
}


resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  depends_on = [ azurerm_virtual_network.virtual_network ]
  name                         = "vnet1-to-vnet2"
  resource_group_name          = azurerm_virtual_network.virtual_network.resource_group_name
  virtual_network_name         = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id    = azurerm_virtual_network.virtual_network_new.id
  allow_virtual_network_access = true
}

# Create peering from vnet2 to vnet1
resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  depends_on = [ azurerm_virtual_network.virtual_network_new ]
  name                         = "vnet2-to-vnet1"
  resource_group_name          = azurerm_virtual_network.virtual_network_new.resource_group_name
  virtual_network_name         = azurerm_virtual_network.virtual_network_new.name
  remote_virtual_network_id    = azurerm_virtual_network.virtual_network.id
  allow_virtual_network_access = true
}

# Needed to create DNS zone and link that bastion VM to default nodegroup for accesing private clsuter
/*resource "azurerm_private_dns_zone_virtual_network_link" "link_bastion_cluster" {
  name = "dnslink-bastion-cluster"
  # The Terraform language does not support user-defined functions, and so only the functions built in to the language are available for use.
  # The below code gets the private dns zone name from the fqdn, by slicing the out dns prefix
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn))))
  resource_group_name   = "MC_kubernetes-core_${azurerm_kubernetes_cluster.k8s.name}_westeurope"
  virtual_network_id    = azurerm_virtual_network.virtual_network_new.id
}*/