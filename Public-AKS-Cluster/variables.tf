variable "rgname" {
  type = string
  description = "resource roup name"
}


variable "location" {
  type = string
  
}

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

variable "subscription_id" {
  type = string
}

variable "location_short_name" {
  type = string
}

variable "tags" {
  type        = map(any)
  description = "The default tags to add to all resources"
}