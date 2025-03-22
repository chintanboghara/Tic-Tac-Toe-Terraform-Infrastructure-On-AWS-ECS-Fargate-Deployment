output "host" {
  value       = docker_container.database.name
  description = "Name of the database container, used as the host for database connections"
}