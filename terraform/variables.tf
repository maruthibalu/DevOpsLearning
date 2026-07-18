variable "prefix" {
  description = "Name prefix for all resources"
  type        = string
  default     = "devops-vm"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key to configure on the VM"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the VM. Set to your public IP range for better security"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    project = "devops-learning"
    managed = "terraform"
  }
}
