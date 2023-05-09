resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region

  tags = var.tags
}

module "network" {
  source = "../../terraform-modules-azure/network/vnet/"

  for_each = {
    for vnet in var.vnets :
    vnet.name => vnet
  }
  region              = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = each.key
  address_spaces      = each.value.address_spaces
  subnets             = each.value.subnets

  tags = var.tags
}

# Required so we can define the Azure App Gateway Subnet to the AKS RouteTable
resource "azurerm_route_table" "this" {
  name                = "aks-routetable"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# Here we add the AKS Subnet to the routetable
resource "azurerm_subnet_route_table_association" "aks_subnet" {
  subnet_id      = module.network["aks-vnet"].vnet_subnets["aks-subnet"].id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_virtual_network_peering" "aks_acr" {
  name                      = "akstoacr"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.network["aks-vnet"].vnet_name
  remote_virtual_network_id = module.network["acr-vnet"].vnet_id
}

resource "azurerm_virtual_network_peering" "acr_to_aks" {
  name                      = "acrtoaks"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.network["acr-vnet"].vnet_name
  remote_virtual_network_id = module.network["aks-vnet"].vnet_id
}
