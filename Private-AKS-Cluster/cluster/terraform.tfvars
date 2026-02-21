rgname                    = "dev-core"
location                  = "West Europe"
security_group            = "dev-core-sg"
azurerm_virtual_network   = "dev-core-vnet"
azurerm_lb                = "dev-core-lb"
publicip                  = "dev-core-pip"
subscription_id           = "ADD_SUBSCRIPTION_ID"
location_short_name       = "westeurope"
kubernetes_version        = "1.32.0"
aks_vnet_address_prefix   = "10.0.0.0/16"
aks_subnet_address_prefix = "10.0.1.0/24"
tags = {
  env = "dev"
}