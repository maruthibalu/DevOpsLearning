variable "name" {
  description = "Name of Azure Virtual Network Manager."
  type        = string
}

variable "location" {
  description = "Azure region for Azure Virtual Network Manager."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing Azure Virtual Network Manager."
  type        = string
}

variable "subscription_ids" {
  description = "Subscription resource IDs included in the AVNM scope."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.subscription_ids :
      can(regex("^/subscriptions/[0-9a-fA-F-]{36}$", id))
    ])
    error_message = "Each subscription must be a complete Azure subscription resource ID."
  }
}