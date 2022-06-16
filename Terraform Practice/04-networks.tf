resource "azurerm_virtual_network" "vm-network" {
  name                = var.vnet-name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm-group.location
  resource_group_name = azurerm_resource_group.vm-group.name
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.vm-group.name
  virtual_network_name = azurerm_virtual_network.vm-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "lb-ip" {
  name                = "lb-ip"
  resource_group_name = azurerm_resource_group.vm-group.name
  location            = azurerm_resource_group.vm-group.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "load-bal" {

  name                = "LoadBal"
  location            = azurerm_resource_group.vm-group.location
  resource_group_name = azurerm_resource_group.vm-group.name

  frontend_ip_configuration {
    name                 = "public-ip-address"
    public_ip_address_id = azurerm_public_ip.lb-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backend" {
  loadbalancer_id = azurerm_lb.load-bal.id
  name            = "backend-address-pool"
}


resource "azurerm_lb_probe" "web-probe" {
  loadbalancer_id = azurerm_lb.load-bal.id
  name            = "web-probe"
  port            = 80
}

resource "azurerm_lb_rule" "http" {

  loadbalancer_id                = azurerm_lb.load-bal.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-ip-address"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend.id]
  probe_id                       = azurerm_lb_probe.web-probe.id
}

resource "azurerm_network_interface_backend_address_pool_association" "connect" {
  network_interface_id    = azurerm_network_interface.vm-nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend.id

  depends_on = [
    azurerm_network_interface.vm-nic
  ]
}

resource "azurerm_lb_nat_rule" "ssh-rule" {
  resource_group_name            = azurerm_resource_group.vm-group.name
  loadbalancer_id                = azurerm_lb.load-bal.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = 1022
  backend_port                   = 22
  frontend_ip_configuration_name = "public-ip-address"
}

resource "azurerm_network_interface_nat_rule_association" "nat-connect" {
  network_interface_id  = azurerm_network_interface.vm-nic.id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.ssh-rule.id
}