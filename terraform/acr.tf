resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = true

  dynamic "network_rule_set" {
    for_each = length(var.acr_allowed_public_ips) > 0 ? [1] : []
    content {
      default_action = "Deny"
      dynamic "ip_rule" {
        for_each = toset(var.acr_allowed_public_ips)
        content {
          ip_range = ip_rule.key
          action   = "Allow"
        }
      }
    }
  }
}

resource "azurerm_private_dns_zone" "azurecr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet" {
  name                  = "aks_vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azurecr.name
  virtual_network_id    = module.network["aks-vnet"].vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_vnet" {
  name                  = "acr_vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azurecr.name
  virtual_network_id    = module.network["acr-vnet"].vnet_id
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pvep-acr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network["acr-vnet"].vnet_subnets["acr-subnet"].id

  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.azurecr.name
    private_dns_zone_ids = [azurerm_private_dns_zone.azurecr.id]
  }
}