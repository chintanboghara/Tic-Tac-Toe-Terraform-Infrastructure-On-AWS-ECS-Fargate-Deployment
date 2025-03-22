resource "docker_volume" "db_data" {
  name = "db_data"
}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_container" "database" {
  name  = "database"
  image = docker_image.postgres.name
  networks_advanced {
    name = var.network_name
  }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }
  volumes {
    host_path      = abspath("${path.module}/../../database/init.sql")
    container_path = "/docker-entrypoint-initdb.d/init.sql"
  }
  env = [
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=mydb"
  ]
}

variable "network_name" {
  type = string
}

variable "db_password" {
  type = string
}

output "host" {
  value = docker_container.database.name
}