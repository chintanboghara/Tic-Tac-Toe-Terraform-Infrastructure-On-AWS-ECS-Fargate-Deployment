resource "docker_image" "frontend" {
  name = "frontend:latest"
  build {
    context = abspath("${path.module}/../../frontend")
  }
}

resource "docker_container" "frontend" {
  name  = "frontend"
  image = docker_image.frontend.name
  networks_advanced {
    name = var.network_name
  }
  ports {
    internal = 80
    external = var.host_port
  }
}

variable "network_name" {
  type = string
}

variable "backend_url" {
  type = string
}

variable "host_port" {
  type = number
}

output "container_name" {
  value = docker_container.frontend.name
}