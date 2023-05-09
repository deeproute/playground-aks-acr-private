locals {
  node_subnets = { for node in var.node_pools :
    node.name => module.network["aks-vnet"].vnet_subnet_names[node.subnet_name]
  }
}

module "aks" {
  #source                   = "git@github.com:deeproute/terraform-modules-azure//aks?ref=master"
  source = "../../terraform-modules-azure/containers/aks/"

  region                  = var.region
  resource_group_name     = var.resource_group_name
  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  identity_ids            = [azurerm_user_assigned_identity.aks_user.id]
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = azurerm_private_dns_zone.azmk8s.id
  network_plugin          = var.network_plugin
  network_policy          = var.network_policy
  node_pools              = var.node_pools
  node_subnets            = local.node_subnets

  tags = var.tags

  depends_on = [
    module.network,
    azurerm_route_table.this,
    azurerm_private_dns_zone.azmk8s
  ]
}

resource "azurerm_private_dns_zone" "azmk8s" {
  name                = "privatelink.eastus2.azmk8s.io"
  resource_group_name = azurerm_resource_group.rg.name
}