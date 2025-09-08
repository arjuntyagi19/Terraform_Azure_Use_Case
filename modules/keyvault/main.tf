data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "kv-weather"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  soft_delete_enabled = true
}

resource "azurerm_key_vault_secret" "sample_secret" {
  name         = "weather-api-key"
  value        = "xyz123"
  key_vault_id = azurerm_key_vault.this.id
}
