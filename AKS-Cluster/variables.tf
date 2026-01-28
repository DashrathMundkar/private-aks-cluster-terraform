variable "rgname" {
  type = string
  description = "resource roup name"
}


variable "location" {
  type = string
  
}

/*variable "storage_account_name" {
  type = string
}

variable "azurerm_storage_container" {
  type = string
}*/

variable "security_group" {
  type = string
}

variable "azurerm_virtual_network" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "azurerm_lb" {
  type = string
}

variable "publicip" {
  type = string
}