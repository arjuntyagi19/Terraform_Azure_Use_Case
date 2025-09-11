terraform {
  required_version = ">=1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~>1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------------------------------------
# Resource Group
# --------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# --------------------------------------------------
# Storage Account + Containers (Dynamic)
# --------------------------------------------------
resource "azurerm_storage_account" "datalake" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

# --------------------------------------------------
# Azure Data Factory + Pipelines (Dynamic)
# --------------------------------------------------
resource "azurerm_data_factory" "df" {
  name                = var.data_factory_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_data_factory_pipeline" "pipelines" {
  for_each        = var.pipelines
  name            = each.key
  data_factory_id = azurerm_data_factory.df.id
  activities_json = file(each.value)
}

# --------------------------------------------------
# Databricks Workspace + Cluster (Dynamic)
# --------------------------------------------------
resource "azurerm_databricks_workspace" "dbw" {
  name                = var.databricks_workspace_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.databricks_sku
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.dbw.id
}

resource "databricks_cluster" "this" {
  cluster_name            = "${var.databricks_workspace_name}-cluster"
  spark_version           = "13.3.x-scala2.12"
  node_type_id            = var.databricks_cluster.node_type_id
  autotermination_minutes = var.databricks_cluster.autotermination_minutes
  num_workers             = var.databricks_cluster.num_workers
}

# --------------------------------------------------
# Azure SQL (MSSQL Server + DBs)
# --------------------------------------------------
resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "dbs" {
  for_each       = var.sql_databases
  name           = each.key
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = each.value       # e.g., "S0"
  max_size_gb    = 5                # optional, static for now
}

# --------------------------------------------------
# Role Assignments (Dynamic)
# --------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "assignments" {
  for_each             = var.role_assignments
  scope                = azurerm_resource_group.rg.id
  role_definition_name = each.value
  principal_id         = each.key
}
