resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.vm-group.location
  resource_group_name = azurerm_resource_group.vm-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.vm-ip.id
  }

}

resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                  = "test-vm"
  resource_group_name   = azurerm_resource_group.vm-group.name
  location              = azurerm_resource_group.vm-group.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm-nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/startup/apache-install.sh")

  provisioner "file" {
    source      = "snake.html"
    destination = "index.html"

    connection {
      type        = "ssh"
      user        = "adminuser"
      private_key = file("${path.module}/ssh-keys/terraform-azure.pem")
      host        = azurerm_public_ip.lb-ip.ip_address
      port        = 1022

    }
  }
}

resource "time_sleep" "move" {
  depends_on = [
    azurerm_linux_virtual_machine.linux-vm
  ]
  create_duration = "1m"

    provisioner "remote-exec" {
      inline = [
        "sudo mv index.html /var/www/html -f"
      ]

      connection {
        type        = "ssh"
        user        = "adminuser"
        private_key = file("${path.module}/ssh-keys/terraform-azure.pem")
        host        = azurerm_public_ip.lb-ip.ip_address
        port        = 1022

    }
  }
  
}