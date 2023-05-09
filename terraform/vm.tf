# Create public IPs
resource "azurerm_public_ip" "vm" {
  name                = var.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# create a network interface
resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.vm_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = module.network["acr-vnet"].vnet_subnets["acr-subnet"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

module "jumpbox_vm" {
  #source                   = "git@github.com:deeproute/terraform-modules-azure//aks?ref=master"
  source = "../../terraform-modules-azure/compute/vmlinux/"

  region                = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  name                  = var.vm_name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.vm.id]
  ssh_key_autogenerate  = true
}