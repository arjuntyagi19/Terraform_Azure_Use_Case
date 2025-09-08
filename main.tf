

#test comment Deven Patil 1234 diacto aakash sirsh
#devenpatil changes 8/9 
#test comment

#test comment Arjun tyagi 1234 diacto Aakash sir



# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westeurope"
}

resource "azurerm_storage_account" "storage" {
  name                     = "mystoragearjuntyagi" # must be globally unique and 3-24 lowercase letters/numbers
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "TerraformDemo"
  } 
}

resource "azurerm_storage_container" "container" {
  name                  = "tfcontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
 