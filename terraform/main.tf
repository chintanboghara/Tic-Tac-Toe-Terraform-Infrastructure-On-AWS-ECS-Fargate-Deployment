terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.12"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app_network"
}

resource "docker_volume" "db_data" {
  name = "db_data"
}

resource "docker_image" "mysql" {
  name = "mysql:5.7"
}

resource "docker_image" "backend" {
  name = "backend:latest"
  build {
    context = "${path.module}/../app/backend"
  }
}

resource "docker_image" "frontend" {
  name = "frontend:latest"
  build {
    context = "${path.module}/../app/frontend"
  }
}

resource "docker_container" "db" {
  image = docker_image.mysql.name
  name  = "db"
  networks_advanced {
    name = docker_network.app_network.name
  }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }
  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_password}",
    "MYSQL_DATABASE=${var.db_name}"
  ]
}

resource "docker_container" "backend" {
  image = docker_image.backend.name
  name  = "backend"
  networks_advanced {
    name = docker_network.app_network.name
  }
  env = [
    "DB_HOST=db",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=${var.db_name}"
  ]
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.name
  name  = "frontend"
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 80
    external = var.frontend_port
  }
}