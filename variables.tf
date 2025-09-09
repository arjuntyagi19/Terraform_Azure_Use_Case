variable "location" {
  type        = string
  description = "Azure region"
  default     = "East US"
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name"
  default     = "rg-weather-project"
}

variable "sql_admin_password" {
  type        = string
  description = "Admin password for Azure SQL"
  sensitive   = true
}

variable "weather_api_key" {
  type        = string
  description = "API key for weather data"
  sensitive   = true
}
