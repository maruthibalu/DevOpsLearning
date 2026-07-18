output "resource_group_name" {
  description = "Created resource group name"
  value       = azurerm_resource_group.vm.name
}

output "vm_name" {
  description = "Created VM name"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm.ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}
