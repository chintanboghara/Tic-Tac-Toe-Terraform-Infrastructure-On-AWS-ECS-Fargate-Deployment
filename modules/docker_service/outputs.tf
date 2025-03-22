output "container_id" {
  description = "The ID of the created Docker container."
  value       = docker_container.service_container.id
}
