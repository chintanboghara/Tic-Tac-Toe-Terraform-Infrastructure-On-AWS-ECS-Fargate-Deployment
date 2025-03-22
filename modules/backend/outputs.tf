output "url" {
  value       = "http://${docker_container.backend.name}:3000"
  description = "URL of the backend service"
}