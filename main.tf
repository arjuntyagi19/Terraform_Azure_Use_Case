provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "datalake" {
  name                     = "weatherstorage01"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "transform" {
  name                  = "transform"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "curate" {
  name                  = "curate"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "dropzone" {
  name                  = "dropzone"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-weather"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "weather-api-key"
  value        = var.weather_api_key
  key_vault_id = azurerm_key_vault.main.id
}

# Data Factory
resource "azurerm_data_factory" "main" {
  name                = "adf-weather"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }
}

# SQL Server & DB
resource "azurerm_mssql_server" "main" {
  name                         = "weather-sql-server"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "metadata" {
  name           = "metadata"
  server_id      = azurerm_mssql_server.main.id
  sku_name       = "S0"
  max_size_gb    = 5
  zone_redundant = false
}

# Databricks Workspace
resource "azurerm_databricks_workspace" "main" {
  name                = "dbx-weather"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "standard"

  tags = {
    env     = "dev"
    project = "weather"
  }
}

# Role Assignments
resource "azurerm_role_assignment" "adf_storage" {
  principal_id         = azurerm_data_factory.main.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.datalake.id
}

resource "azurerm_role_assignment" "adf_kv" {
  principal_id         = azurerm_data_factory.main.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.main.id
}

resource "azurerm_role_assignment" "dbx_storage" {
  principal_id         = azurerm_databricks_workspace.main.managed_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.datalake.id
}

resource "azurerm_role_assignment" "dbx_kv" {
  principal_id         = azurerm_databricks_workspace.main.managed_identity.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.main.id
}
