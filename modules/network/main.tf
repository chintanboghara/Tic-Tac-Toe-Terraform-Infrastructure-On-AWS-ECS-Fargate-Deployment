resource "docker_network" "app_network" {
  name = "app_network"
}

output "name" {
  value = docker_network.app_network.name
}