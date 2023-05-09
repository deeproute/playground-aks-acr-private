### AKS User Identity
resource "azurerm_user_assigned_identity" "aks_user" {
  name                = "aks-user"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
}

resource "azurerm_role_assignment" "aks_user_identity_operator" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_user.principal_id
}

# Required for Network Reads (Service Type LoadBalancer)
resource "azurerm_role_assignment" "aks_user_reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks_user.principal_id
}

# Required for RouteTable Updates
resource "azurerm_role_assignment" "aks_user_routetable_network_contrib" {
  scope                = azurerm_route_table.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user.principal_id
}

# Required for Internal LB Updates
resource "azurerm_role_assignment" "aks_user_vnet_network_contrib" {
  scope                = module.network["aks-vnet"].vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user.principal_id
}

resource "azurerm_role_assignment" "aks_kubelet_acrpull" {
  principal_id                     = module.aks.kubelet_identity.object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_user_pvt_dns_contrib" {
  scope                = azurerm_private_dns_zone.azmk8s.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user.principal_id
}