output "id" {
  description = "Resource ID of the Log analytics workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "workspace_id" {
  description = "Workspace ID used by monitoring integrations."
  value       = azurerm_log_analytics_workspace.law.workspace_id
}