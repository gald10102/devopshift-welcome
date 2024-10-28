# Terraform script to set up a Linux Virtual Machine in Azure with Apache installed

provider "azurerm" {
  features {}
}

# Variables for configurable parameters
variable "admin_username" {
  default = "adminuser-yaniv"
  description = "Username for the admin user on the VM"
}

variable "admin_password" {
  default = "Password123!"
  description = "Password for the admin user on the VM"
}

variable "location" {
  default = "East US"
  description = "Azure region where resources will be deployed"
}

variable "vm_size" {
  default = "Standard_B1ms"
  description = "Size of the virtual machine"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-yaniv"
  location = var.location
}

# Network Security Group to allow HTTP and SSH access
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-yaniv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Public IP for the VM
resource "azurerm_public_ip" "pip" {
  name                = "pip-yaniv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Network Interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "nic-yaniv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Virtual Network for the subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-yaniv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet within the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-yaniv"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Linux Virtual Machine configuration
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "yaniv-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "yaniv-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false
  computer_name                   = "yaniv-vm"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Ignore changes to the network interface to avoid unnecessary recreation of the VM
  lifecycle {
    ignore_changes = [network_interface_ids]
  }

  depends_on = [azurerm_network_interface.nic, azurerm_public_ip.pip]
}

# Network Security Rule to Allow HTTP (Port 80) and SSH (Port 22)
resource "azurerm_network_security_rule" "allow_http_ssh" {
  name                        = "allow-http-ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "22"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Data source to reference the latest public IP after creation
data "azurerm_public_ip" "example" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_resource_group.rg.name
}

# Updated Null Resource for Apache Installation with correct IP reference
resource "null_resource" "provision_apache" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  # Trigger to force rerun whenever timestamp changes
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
      "echo '<h1>Welcome to \"${azurerm_linux_virtual_machine.vm.computer_name}\" Web Server!</h1>' | sudo tee /var/www/html/welcome.html",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = data.azurerm_public_ip.example.ip_address
      timeout  = "1m"
    }
  }
}

# Updated Output for Server Information to use data source
output "server_info" {
  value       = "Please browse: http://${data.azurerm_public_ip.example.ip_address}:80/welcome.html"
  description = "Instructions to access the server, noting that port 80 is currently blocked."
}