terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.15.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "docker" {
  # Configuration options can be provided here if needed.
}

# Create a Docker network for our services
resource "docker_network" "app_network" {
  name = "app_network"
}

# Use the docker_service module to create an Nginx container
module "nginx_service" {
  source = "./modules/docker_service"

  container_name = "nginx_container"
  image          = "nginx:latest"
  network_id     = docker_network.app_network.id

  # Environment variables and port mapping can be set in the module
  ports = [
    {
      internal = 80
      external = 8080
    }
  ]
}
