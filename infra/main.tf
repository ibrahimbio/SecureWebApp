# Azure Provider
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}

# Service Plan (Linux, S1)
resource "azurerm_service_plan" "main" {
  name                = "SecurePlan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Web App
resource "azurerm_linux_web_app" "main" {
  name                = var.webapp_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  site_config {
    dotnet_framework_version = "v9.0"
  }
  https_only = true
}

# Staging Slot
resource "azurerm_linux_web_app_slot" "staging" {
  name                = "staging"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  site_config {
    dotnet_framework_version = "v9.0"
  }
  app_service_plan_id = azurerm_service_plan.main.id
  parent_app_name     = azurerm_linux_web_app.main.name
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = var.kv_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  soft_delete_enabled         = true
}

# Key Vault Secret
resource "azurerm_key_vault_secret" "db_password" {
  name         = "DbPassword"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
}

# Tenant info
data "azurerm_client_config" "current" {}
