resource "azurerm_databricks_workspace" "this" {
  name                = "dbx-weather"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "standard"

  tags = {
    environment = "weather"
    type        = "databricks"
  }
}
