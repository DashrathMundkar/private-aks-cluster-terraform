resource "azurerm_firewall" "aks_firewall" {
  name                = var.firewall_name
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}

resource "azurerm_firewall_policy" "dev-firewall-policy" {
  name                = "dev-firewall-policy"
  resource_group_name = azurerm_resource_group.firewall_rg.name
  location            = var.location
  sku                 = "Standard"
}