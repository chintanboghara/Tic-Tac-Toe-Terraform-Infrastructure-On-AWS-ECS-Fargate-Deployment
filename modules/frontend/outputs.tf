output "container_name" {
  value       = docker_container.frontend.name
  description = "Name of the frontend container"
}