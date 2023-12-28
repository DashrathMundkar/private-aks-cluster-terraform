/*resource "azurerm_public_ip" "publicip" {
  name                = var.publicip
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_lb" "akslb" {
  depends_on = [ azurerm_public_ip.publicip ]
  name                = var.azurerm_lb
  location            = var.location
  resource_group_name = var.rgname
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}*/