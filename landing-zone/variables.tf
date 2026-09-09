variable "location" {
  description = "Primary Azure region for landing-zone resources."
  type        = string
  default     = "eastus"
}

variable "sku" {
  description = "SKU used by the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Log Analytics workspace retention period."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30
    error_message = "Log Analytics retention must be at least 30 days."
  }
}