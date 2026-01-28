resource "azurerm_kubernetes_cluster" "k8s" {
  depends_on = [ azurerm_virtual_network.virtual_network ]
  name                = var.rgname
  location            = var.location
  resource_group_name = var.rgname
  dns_prefix          = var.rgname
  kubernetes_version = var.kubernetes_version
  private_cluster_enabled = false

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    os_disk_size_gb = 30
    os_sku                = "Ubuntu"  
    vnet_subnet_id = azurerm_subnet.subnet1.id
  
  }

  network_profile {
    network_plugin     = "kubenet"
    dns_service_ip     = "192.168.1.1"
    service_cidr       = "192.168.0.0/16"
    pod_cidr           = "172.16.0.0/22"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "staging"
  }
}

/*resource "azurerm_kubernetes_cluster_node_pool" "example" {
  name                  = "custom"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_sku                = "Ubuntu"
  os_type               = "Linux"        

  tags = {
    Environment = "statging"
  }
}*/