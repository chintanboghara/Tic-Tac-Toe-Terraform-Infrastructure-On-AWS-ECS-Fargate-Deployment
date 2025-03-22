variable "network_name" {
  type        = string
  description = "Name of the Docker network to connect the backend container to"
}

variable "db_host" {
  type        = string
  description = "Host name of the database container"
}

variable "db_password" {
  type        = string
  description = "Password for the PostgreSQL database"
  sensitive   = true
}