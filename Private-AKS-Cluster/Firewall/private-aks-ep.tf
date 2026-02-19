data "azurerm_kubernetes_cluster" "dev-aks" {
  name                = "dev-core"
  resource_group_name = "dev-core"
}

resource "azurerm_private_endpoint" "dev-k8s" {
    name                = "dev-k8s-pep"
    resource_group_name = "dev-core"
    location            = var.location
    subnet_id           = azurerm_subnet.pep.id
    
    private_service_connection {
        name                           = "dev-k8s-psc"
        is_manual_connection            = false
        private_connection_resource_id   = data.azurerm_kubernetes_cluster.dev-aks.id
        subresource_names                = ["management"]
    }
    lifecycle {
    ignore_changes = [
      name,
      private_service_connection
    ]
  }
}


/*data "azurerm_private_link_service" "dev-ingress-intranet" {
  name                = "pl-ingress-intranet"
  resource_group_name = "dev-core"
}

resource "azurerm_private_endpoint" "dev-ingress-intranet" {
  name                = "pep-ingress-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.firewall_rg.name
  subnet_id           = azurerm_subnet.pep.id

  private_service_connection {
    name                           = "dev-ingress-intranet"
    is_manual_connection           = false
    private_connection_resource_id = data.azurerm_private_link_service.dev-ingress-intranet.id
    # subresource_names MUST be omitted for Private Link Service connections
  }
}*/
