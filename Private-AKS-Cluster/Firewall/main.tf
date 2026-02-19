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
    name     = "NAT_INGRESS_DEV"
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
    name     = "aksfwnr"
    priority = 105
    action   = "Allow"

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
      name              = "time"
      protocols         = ["UDP"]
      source_addresses  = ["*"]
      destination_fqdns = ["ntp.ubuntu.com"]
      destination_ports = ["123"]
    }

    rule {
      name              = "ghcr"
      protocols         = ["TCP"]
      source_addresses  = ["*"]
      destination_fqdns = ["ghcr.io", "pkg-containers.githubusercontent.com"]
      destination_ports = ["443"]
    }

    rule {
      name              = "docker"
      protocols         = ["TCP"]
      source_addresses  = ["*"]
      destination_fqdns = ["docker.io", "registry-1.docker.io", "production.cloudflare.docker.com"]
      destination_ports = ["443"]
    }
  }

  application_rule_collection {
    name     = "aksfwar"
    priority = 110
    action   = "Allow"

    rule {
      name             = "fqdn"
      source_addresses = ["*"]

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
  }
}
