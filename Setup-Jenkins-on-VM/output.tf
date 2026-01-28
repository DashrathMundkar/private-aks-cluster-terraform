output "vm_public_ip" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.pub-ip.ip_address
}
