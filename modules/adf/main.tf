resource "azurerm_data_factory" "this" {
  name                = "adf-weather"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}
