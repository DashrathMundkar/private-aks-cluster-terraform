resource "azurerm_firewall" "aks_firewall" {
  name                = var.firewall_name
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.dev-firewall-policy.id

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}

resource "azurerm_firewall_policy" "dev-firewall-policy" {
  name                = var.firewall_name
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  sku                 = "Standard"
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

  network_rule_collection {
    name     = "aksfwnr"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "time"
      source_addresses      = ["*"]
      destination_ports     = ["123"]
      destination_addresses = ["*"]
      protocols = [
        "UDP"
      ]
    }
    rule {
      name                  = "apitcp"
      source_addresses      = ["*"]
      destination_ports     = ["9000"]
      destination_addresses = ["AzureCloud.${var.location}"]
      protocols = [
        "TCP"
      ]
    }
    rule {
      name                  = "apiudp"
      source_addresses      = ["*"]
      destination_ports     = ["1194"]
      destination_addresses = ["AzureCloud.${var.location}"]
      protocols = [
        "UDP"
      ]
    }
    rule {
      name              = "allow service tags"
      source_addresses  = ["*"]
      destination_ports = ["*"]
      destination_addresses = [
        "AzureContainerRegistry.${var.location}",
        "MicrosoftContainerRegistry.${var.location}",
        "AzureActiveDirectory",
        "AzureMonitor",
        "AzureWebPubSub",
        "Storage",
        "StorageSyncService",
        "AzureKubernetesService"
      ]
      protocols = [
        "Any"
      ]
    }
  }
  application_rule_collection {
    name     = "UbuntuOsUpdates"
    priority = 102
    action   = "Allow"
    rule {
      name             = "allow network"
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefixes[0]]
      destination_fqdns = [
        "download.opensuse.org",
        "security.ubuntu.com",
        "packages.microsoft.com",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com",
        "snapcraft.io",
        "api.snapcraft.io",
        "motd.ubuntu.com"
      ]
      protocols {
        port = 443
        type = "Https"
      }
      protocols {
        port = 80
        type = "Http"
      }
    }
    rule {
      name = "Egress to Azure services"
      protocols {
        port = 443
        type = "Https"
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses      = [data.azurerm_subnet.aks_subnet.address_prefixes[0]]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }
    rule {
      name = "Egress to DockerHub"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        port = 80
        type = "Http"
      }
      source_addresses  = [data.azurerm_subnet.aks_subnet.address_prefixes[0]]
      destination_fqdns = ["acs-mirror.azureedge.net", "packages.aks.azure.com"]
    }
    rule {
      name             = "allow networks for docker"
      source_addresses = [data.azurerm_subnet.aks_subnet.address_prefixes[0]]
      destination_fqdns = [
        "*docker.io",
        "*hub.docker.com",
        "*auth.docker.io",
        "*index.docker.io",
        "*registry-1.docker.io",
        "*cloudflarestorage.com",
        "*cloudflare.docker.io",
        "*cloudflare.docker.com",
        "*production.cloudflare.docker.com",
      ]
      protocols {
        port = "443"
        type = "Https"
      }
      protocols {
        port = "80"
        type = "Http"
      }
    }
  }
}