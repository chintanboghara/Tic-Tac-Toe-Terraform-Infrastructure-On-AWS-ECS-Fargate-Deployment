output "nginx_container_id" {
  description = "The ID of the deployed Nginx container"
  value       = module.nginx_service.container_id
}
