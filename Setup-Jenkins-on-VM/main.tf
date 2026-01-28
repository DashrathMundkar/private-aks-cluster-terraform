terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "~>4.53.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg-name" {
  name     = var.azurerm_resource_group
  location = var.azurerm_location
}

resource "azurerm_virtual_network" "vnet-name" {
  name                = "${var.azurerm_resource_group}-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = var.azurerm_location
  resource_group_name = var.azurerm_resource_group
}

resource "azurerm_subnet" "subnet-name" {
  name                 = "${var.azurerm_resource_group}-SUBNET"
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = azurerm_virtual_network.vnet-name.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pub-ip" {
  name                = "${var.azurerm_resource_group}-PublicIP"
  location            = var.azurerm_location
  resource_group_name = var.azurerm_resource_group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.azurerm_resource_group}-NIC"
  location            = var.azurerm_location
  resource_group_name = var.azurerm_resource_group

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet-name.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub-ip.id
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name

  security_rule {
    name                       = "AllowedInboundSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowedInboundHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
      name                       = "AllowedInboundHTTPS"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
    security_rule {
        name                       = "AllowedInboundJenkinsPort"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_network_interface_security_group_association" "associate" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}