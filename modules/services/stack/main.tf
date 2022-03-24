
resource "azurerm_resource_group" "vmss" {
  name     = "${var.stack_name}-rg"
  location = var.location
  tags     = var.tags
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_virtual_network" "vmss" {
  name                = "${var.stack_name}-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  tags                = var.tags
}

resource "azurerm_subnet" "vmss" {
  name                 = "${var.stack_name}-vmss-subnet"
  resource_group_name  = azurerm_resource_group.vmss.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
  name                = "${var.stack_name}-vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

resource "azurerm_lb" "vmss" {
  name                = "${var.stack_name}-vmss-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "secgroup" {
  depends_on = [
    azurerm_resource_group.vmss
  ]
  resource_group_name = azurerm_resource_group.vmss.name
  name                = "${var.stack_name}-secgroup"
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_address_prefix      = "68.206.65.233/32"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  # security_rule {
  #   name                       = "HTTP"
  #   priority                   = 101
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "TCP"
  #   source_address_prefix      = "*"
  #   source_port_range          = "*"
  #   destination_address_prefix = "*"
  #   destination_port_range     = "8080"
  # }
}


resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "${var.stack_name}-BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  resource_group_name = azurerm_resource_group.vmss.name
  loadbalancer_id     = azurerm_lb.vmss.id
  name                = "${var.stack_name}-ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = azurerm_resource_group.vmss.name
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "${var.stack_name}-http-nat-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.stack_name}-vmscaleset"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  instances           = 2
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_ssh_public_key
  }
  custom_data = var.custom_data

  sku = "Standard_DS1"

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${var.stack_name}-terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  tags = var.tags
}

data "azurerm_key_vault" "keyvault" {
  resource_group_name = "tfstate"
  name                = "examplekeys"
}

data "azurerm_key_vault_secret" "dbpassword" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

output "secret_value" {
  value     = data.azurerm_key_vault_secret.dbpassword.value
  sensitive = true
}

resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.stack_name}-jumpbox-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  domain_name_label   = "${random_string.fqdn.result}-ssh"
  tags                = var.tags
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.stack_name}-jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.vmss.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "sga" {
  network_interface_id      = azurerm_network_interface.jumpbox.id
  network_security_group_id = azurerm_network_security_group.secgroup.id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "${var.stack_name}-jumpbox"
  location              = var.location
  resource_group_name   = azurerm_resource_group.vmss.name
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  size                  = "Standard_DS1"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name  = "jumpbox"
  admin_username = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = var.tags
}
