resource "azurerm_kubernetes_cluster" "k8s" {
  name                        = var.rgname
  location                    = var.location
  resource_group_name         = var.rgname
  dns_prefix                  = var.rgname
  kubernetes_version          = var.kubernetes_version
  private_cluster_enabled     = false

  default_node_pool {
    name                      = "system"
    node_count                = 1
    vm_size                   = "Standard_D2ads_v5"
    os_disk_size_gb           = 30
    os_sku                    = "Ubuntu"  
    vnet_subnet_id            = azurerm_subnet.aks_subnet.id
    orchestrator_version      = var.kubernetes_version
    max_pods                  = 60 
    tags                      = var.tags
    only_critical_addons_enabled = true
  }

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true

  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    load_balancer_sku   = "standard" # For ssl probes and multiple node pools
    outbound_type       = "loadBalancer"
    service_cidr        = "172.20.0.0/16"
    dns_service_ip      = "172.20.0.10" 
  }

  identity {
    type = "SystemAssigned"
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    day_of_week = "Monday"
    start_time  = "08:00"
    utc_offset  = "+02:00"
    duration    = 10
    interval    = 1
  }

  # Do node OS image updates every monday
  maintenance_window_node_os {
    frequency   = "Weekly"
    day_of_week = "Monday"
    start_time  = "08:00"
    utc_offset  = "+02:00"
    duration    = 10
    interval    = 1
  }

  lifecycle {
    ignore_changes = [
      microsoft_defender,
      kubernetes_version, # Always upgrade kubernetes cluster manually because terraform should not manage the cluster version.
      default_node_pool["orchestrator_version"],
      image_cleaner_interval_hours,
      node_os_upgrade_channel,
      maintenance_window_auto_upgrade,
      upgrade_override
    ]
  }
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

resource "azurerm_role_definition" "custom_role" {
  name        = "CustomK8sAdmin"
  scope       = azurerm_kubernetes_cluster.k8s.id
  description = "Custom role for managing AKS cluster"

  permissions {
    actions = [
      "Microsoft.network/virtualNetworks/subnets/join/action",
      "Microsoft.network/virtualNetworks/subnets/read",
    ]
  }
}

resource "azurerm_role_assignment" "custom_role_assignment" {
  scope              = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "CustomK8sAdmin"
  principal_id       = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# Extra user node pool for application pods
/*resource "azurerm_kubernetes_cluster_node_pool" "application" {
  name                  = "application"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.aks.id
  max_pods              = 60
  orchestrator_version  = var.kubernetes_version
  lifecycle {
    ignore_changes = [
      orchestrator_version,
      upgrade_settings
    ]
  }
}*/