output "container_id" {
  description = "ID of the deployed Docker container"
  value       = module.app_container.container_id
}

output "container_status" {
  description = "Status of the deployed Docker container"
  value       = module.app_container.container_status
}
