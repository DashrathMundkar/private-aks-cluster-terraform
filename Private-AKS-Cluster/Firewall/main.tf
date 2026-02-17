resource "azurerm_resource_group" "firewall_rg" {
  name     = "firewall-rg"
  location = var.location
}

/*data "azurerm_virtual_network" "dev-vn" {
  name                = "dev-core-vnet"
  resource_group_name = "dev-core"
}

data "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet" 
  virtual_network_name = data.azurerm_virtual_network.dev-vn.name
  resource_group_name  = data.azurerm_virtual_network.dev-vn.resource_group_name
}*/

resource "azurerm_firewall_policy_rule_collection_group" "fw-rules" {
    name                = "dev-rule-collection-group"
    firewall_policy_id  = azurerm_firewall_policy.dev-firewall-policy.id
    priority            = 500
  

  application_rule_collection {
    name     = "Allow-AKS"
    priority = 205
    action   = "Allow"

    rule {
      name             = "Egress to Azure services"
      #source_addresses = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_fqdn_tags = ["AzureKubernetesService"]

      protocols {
        type = "Https"
        port = 443
      }
    }
    rule {
      name             = "Egress to api Azure services"
      #source_addresses = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_fqdn_tags = ["dev-core-z3okj826.hcp.westeurope.azmk8s.io"]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }
    
  nat_rule_collection {
    action = "Dnat"
    name   = "NAT_INGRESS_DEV"
    priority = 305
    rule {
      name                       = "DEV_INGRESS_HTTP"
      description                = "DNAT rule to allow inbound traffic to AKS API server"
      source_addresses           = ["*"]
      destination_address        = azurerm_public_ip.firewall_public_ip.ip_address
      destination_ports          = ["80"]
      protocols                  = ["TCP"]
      translated_address         = "10.0.1.63" # kuberntes internal load balancer IP created by istio service of type LoadBalancer
      translated_port            = "80"
    }
    rule {
      name                       = "DEV_INGRESS_HTTPS"
      description                = "DNAT rule to allow inbound traffic to AKS API server"
      source_addresses           = ["*"]
      destination_address        = azurerm_public_ip.firewall_public_ip.ip_address
      destination_ports          = ["443"]
      protocols                  = ["TCP"]
      translated_address         = "10.0.1.63" # kuberntes internal load balancer IP created by istio service of type LoadBalancer
      translated_port            = "80"
    }
  }
  application_rule_collection {
    action = "Allow"
    name = "APP_INGRESS_DEV"
    priority = 310
    rule {
      name                       = "DEV_INGRESS_HTTP_APP_RULE"
      description                = "Application rule to allow inbound traffic to AKS API server"
      #source_addresses           = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_addresses      = [azurerm_public_ip.firewall_public_ip.ip_address]
      destination_fqdns          = ["www.google.com"]
      
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}