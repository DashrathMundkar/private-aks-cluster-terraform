resource "azurerm_virtual_machine" "vm-name" {
  name                = "${var.azurerm_resource_group}-VM"
  location            = var.azurerm_location
  resource_group_name = var.azurerm_resource_group
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_D2s_v3"    

    storage_os_disk {
        name              = "${var.azurerm_resource_group}-OSDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }   
    os_profile {
        computer_name  = "${var.azurerm_resource_group}-VM"
        admin_username = var.vm_admin_username
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
            key_data = file(var.vm_public_key_path)
        }
    }
}

resource "azurerm_virtual_machine_extension" "jenkins_setup" {
  name                 = "JenkinsSetupExtension"
  virtual_machine_id   = azurerm_virtual_machine.vm-name.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  protected_settings = jsonencode({
    script = base64encode(file("${path.module}/jenkins_setup.sh"))
  })

  depends_on = [azurerm_virtual_machine.vm-name]
}

