module "storage" {
  source              = "./modules/storage"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "keyvault" {
  source              = "./modules/keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "adf" {
  source              = "./modules/adf"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "sql" {
  source              = "./modules/sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  sql_admin_password  = var.sql_admin_password
}

module "databricks" {
  source              = "./modules/databricks"
  location            = var.location
  resource_group_name = var.resource_group_name
}
