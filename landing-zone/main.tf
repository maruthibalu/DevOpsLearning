data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "connectivity" {
  name     = "rg-platform-connectivity"
  location = var.location
}

resource "azurerm_resource_group" "law" {
  name     = "rg-platform-law"
  location = var.location
}

module "law" {
  source              = "../modules/log-analytics"
  name                = "law-platform"
  location            = var.location
  resource_group_name = azurerm_resource_group.law.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}

module "avnm" {
  source              = "../modules/avnm"
  name                = "avnm-platform"
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivity.name
  subscription_ids    = [data.azurerm_subscription.current.id]
}