#holds variables
variable "rg-location" {
  type    = string
  default = "centralus"
}

variable "rg-name" {
  type    = string
  default = "vm-test-group"
}

variable "vnet-name" {
  type    = string
  default = "vm-network"
}
