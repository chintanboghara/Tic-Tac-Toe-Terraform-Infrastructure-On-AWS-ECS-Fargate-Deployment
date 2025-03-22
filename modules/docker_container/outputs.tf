output "container_id" {
  description = "ID of the deployed Docker container"
  value       = docker_container.app.id
}

output "container_status" {
  description = "Status of the deployed Docker container"
  value       = docker_container.app.status
}
