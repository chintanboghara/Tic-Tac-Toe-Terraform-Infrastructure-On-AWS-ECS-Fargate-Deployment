resource "docker_image" "backend" {
  name = "backend:latest"
  build {
    context = abspath("${path.module}/../../backend")
  }
}

resource "docker_container" "backend" {
  name  = "backend"
  image = docker_image.backend.name
  networks_advanced {
    name = var.network_name
  }
  env = [
    "DB_HOST=${var.db_host}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=mydb"
  ]
}

variable "network_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_password" {
  type = string
}

output "url" {
  value = "http://${docker_container.backend.name}:3000"
}