variable "azurerm_resource_group" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "AzurePlaygroundRG"
}

variable "subscription_id" {
  description = "The Subscription ID for the Azure Resource Group"
  type        = string
}

variable "azurerm_location" {
  description = "The location of the Azure Resource Group"
  type        = string
  default     = "WestEurope"
}
variable "vm_admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "vm_public_key_path" {
  description = "Path to the public SSH key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}