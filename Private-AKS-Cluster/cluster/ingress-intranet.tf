/*resource "azurerm_private_link_service" "ingress_intranet" {
  name                = "pl-ingress-intranet"
  resource_group_name = var.rgname
  location            = var.location
  tags = var.tags 

# Can't use data.azurerm_lb for this, because each change to private link services will reload data.azurerm_lb which will then recreate all private link services
  load_balancer_frontend_ip_configuration_ids = [
    "/subscriptions/62f28128-0f1a-4d05-b22d-8921a5378718/resourceGroups/mc_dev-core_dev-core_westeurope/providers/Microsoft.Network/loadBalancers/kubernetes-internal/frontendIPConfigurations/a6e69ece03ab243aa928da35b2d4bef1"
  ]

  nat_ip_configuration {
    name      = "primary"
    subnet_id = azurerm_subnet.ingress_subnet.id
    primary   = true
  }

  nat_ip_configuration {
    name      = "secondary"
    subnet_id = azurerm_subnet.ingress_subnet.id
    primary   = false
  }
}*/
