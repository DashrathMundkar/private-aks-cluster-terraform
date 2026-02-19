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
  name               = "dev-rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.dev-firewall-policy.id
  priority           = 500

  nat_rule_collection {
    action   = "Dnat"
    name     = "DNAT_NAT_INGRESS_DEV"
    priority = 100

    rule {
      name                = "DEV_INGRESS_HTTP"
      description         = "DNAT rule to allow inbound traffic to AKS ingress"
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.firewall_public_ip.ip_address
      destination_ports   = ["80"]
      protocols           = ["TCP"]
      translated_address  = "10.0.1.64"
      translated_port     = "80"
    }

    rule {
      name                = "DEV_INGRESS_HTTPS"
      description         = "DNAT rule to allow inbound traffic to AKS ingress"
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.firewall_public_ip.ip_address
      destination_ports   = ["443"]
      protocols           = ["TCP"]
      translated_address  = "10.0.1.64"
      translated_port     = "443"
    }
  }

  network_rule_collection {
    name     = "NetRuleCollection"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "AllowDNS"
      protocols             = ["UDP"]
      source_addresses      = [data.azurerm_subnet.aks_subnet.address_prefix]
      destination_addresses = ["209.244.0.3","209.244.0.4"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "apitcp"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["9000"]
    }

    rule {
      name                  = "apiudp"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["1194"]
    }
    rule {
      name              = "ntpudp"
      protocols         = ["UDP"]
      source_addresses  = ["*"]
      destination_addresses = ["185.125.190.57"]
      destination_ports = ["123"]
    }
  }

  application_rule_collection {
    name     = "AppRuleCollection"
    priority = 200
    action   = "Allow"
    
    rule {
      name             = "AllowDockerHubANDUbuntu"
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefix]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdns = ["docker.io", "registry-1.docker.io", "production.cloudflare.docker.com", "auth.docker.io", "index.docker.io", "login.docker.com", "archive.ubuntu.com", "security.ubuntu.com"]
    }

    rule {
      name             = "AllowAzureKubernetesService"
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefix]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdn_tags = ["AzureKubernetesService"]
    }
    rule {
      name             = "AllowGoogle"
      source_addresses = ["*"]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdns = ["www.google.com"]
    }
    }
  }
