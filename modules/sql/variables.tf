variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}
