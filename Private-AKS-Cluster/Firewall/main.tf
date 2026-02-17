resource "azurerm_resource_group" "firewall_rg" {
  name     = "firewall-rg"
  location = var.location
}

data "azurerm_virtual_network" "dev-vn" {
  name                = "dev-core-vnet"
  resource_group_name = "dev-core"
}

data "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet" 
  virtual_network_name = data.azurerm_virtual_network.dev-vn.name
  resource_group_name  = data.azurerm_virtual_network.dev-vn.resource_group_name
}

resource "azurerm_firewall_policy_rule_collection_group" "fw-rules" {
    name                = "dev-rule-collection-group"
    firewall_policy_id  = azurerm_firewall_policy.dev-firewall-policy.id
    priority            = 500
  
  nat_rule_collection {
    action = "Dnat"
    name   = "NAT_INGRESS_DEV"
    priority = 305
    rule {
      name                       = "DEV_INGRESS_HTTP"
      description                = "DNAT rule to allow inbound traffic to AKS API server"
      source_addresses           = ["*"]
      destination_address        = azurerm_public_ip.ip-dev-1.ip_address
      destination_ports          = ["80"]
      protocols                  = ["TCP"]
      translated_address         = "172.16.2.6" # kuberntes internal load balancer IP created by istio service of type LoadBalancer
      translated_port            = "80"
    }
    rule {
      name                       = "DEV_INGRESS_HTTPS"
      description                = "DNAT rule to allow inbound traffic to AKS API server"
      source_addresses           = ["*"]
      destination_address        = azurerm_public_ip.ip-dev-1.ip_address
      destination_ports          = ["443"]
      protocols                  = ["TCP"]
      translated_address         = "172.16.2.6" # kuberntes internal load balancer IP created by istio service of type LoadBalancer
      translated_port            = "443"
    }
  }
  application_rule_collection {
    action = "Allow"
    name = "Allow-Docker-Hub"
    priority = 315
    rule {
      name                       = "Allow-Docker-Hub"
      description                = "Application rule to allow inbound traffic to Docker Hub"
      source_addresses           = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_fqdns           = ["*"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
  network_rule_collection {
    name     = "Allow-AKS-Intranet"
    priority = 320
    action   = "Allow"

    rule {
      name      = "Allow-docker"
      protocols = ["TCP"]
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_addresses = ["168.63.129.16"] # Azure infrastructure IP for DNS resolution
      destination_ports     = ["53"] #ssh clone
    }
  }
}