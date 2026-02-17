/*data "azurerm_kubernetes_cluster" "dev-aks" {
  name                = "dev-core"
  resource_group_name = "dev-core"
}
resource "azurerm_private_endpoint" "dev-k8s" {
    name                = "dev-k8s-pe"
    resource_group_name = "dev-core"
    location            = var.location
    subnet_id           = azurerm_subnet.firewall_subnet.id
    
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
}*/