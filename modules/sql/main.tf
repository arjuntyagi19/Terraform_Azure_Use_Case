resource "azurerm_mssql_server" "this" {
  name                         = "weather-sql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "metadata_db" {
  name           = "metadata"
  server_id      = azurerm_mssql_server.this.id
  sku_name       = "S0"
  max_size_gb    = 5
  zone_redundant = false
}
