# --------------------------------------------------
# Global
# --------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure location/region"
}

# --------------------------------------------------
# Storage
# --------------------------------------------------
variable "storage_account_name" {
  type        = string
  description = "Name of the ADLS Gen2 storage account"
}

variable "containers" {
  type        = list(string)
  default     = ["drop", "raw", "transform", "curated", "logs"]
  description = "List of containers to create in the storage account"
}

# --------------------------------------------------
# Data Factory
# --------------------------------------------------
variable "data_factory_name" {
  type        = string
  description = "Name of the Data Factory"
}

variable "pipelines" {
  type = map(string)
  default = {
    ingest    = "pipelines/ingest.json"
    transform = "pipelines/transform.json"
  }
  description = "Map of pipeline_name = pipeline_definition_file"
}

# --------------------------------------------------
# Databricks
# --------------------------------------------------
variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Databricks workspace"
}

variable "databricks_sku" {
  type    = string
  default = "premium"
}

variable "databricks_cluster" {
  type = object({
    num_workers             = number
    node_type_id            = string
    autotermination_minutes = number
  })
  default = {
    num_workers             = 2
    node_type_id            = "Standard_DS3_v2"
    autotermination_minutes = 30
  }
}

# --------------------------------------------------
# SQL
# --------------------------------------------------
variable "sql_server_name" {
  type        = string
  description = "Name of the Azure SQL server"
}

variable "sql_admin_login" {
  type        = string
  description = "Admin login for SQL server"
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for SQL server"
}

variable "sql_databases" {
  type = map(string)
  default = {
    metadata  = "S0"
    analytics = "S1"
  }
  description = "Map of db_name = sku_name"
}

# --------------------------------------------------
# Role Assignments
# --------------------------------------------------
variable "role_assignments" {
  type = map(string)
  default = {
    # Example: "<object_id_of_sp>" = "Contributor"
  }
  description = "Map of principal_id = role_definition_name"
}
