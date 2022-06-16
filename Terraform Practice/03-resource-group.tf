resource "azurerm_resource_group" "vm-group" {
  name     = var.rg-name
  location = var.rg-location
}