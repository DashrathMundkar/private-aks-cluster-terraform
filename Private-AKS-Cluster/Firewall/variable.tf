variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
}
variable "location" {
  description = "Azure region for the resources"
  type        = string
}
variable "resource_group_name" {

  description = "Name of the resource group"
  type        = string
}

variable "firewall_vnet_name" {
  type = string
}
variable "firewall_subnet_name" {
  type = string
}
variable "tags" {
  type = string
}
variable "subscription_id" {
  type = string
}

variable "nat_gateway_name" {
  type = string

}
variable "pep_subnet" {
  type = string
}
variable "vnet_address_prefix" {
  type = string
}
variable "pep_subnet_prefix" {
  type = string
}