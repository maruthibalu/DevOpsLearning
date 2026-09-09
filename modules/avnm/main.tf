resource "azurerm_network_manager" "avnm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  scope {
    subscription_ids = var.subscription_ids
  }

  scope_accesses = [
    "SecurityAdmin"
  ]

  description = "Central network management for the platform landing zone"
}