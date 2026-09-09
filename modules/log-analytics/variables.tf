variable "name" {
  description = "Name of the Log analytics workspace"
  type        = string
}

variable "location" {
  description = "Azure region for the workspac"
  type        = string
}

variable "resource_group_name" {
  description = "Rescouce group containing workspac"
  type        = string
}

variable "sku" {
  description = "sku for workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "workspace data retention"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30
    error_message = "Retention must be at least 30 days"
  }
}