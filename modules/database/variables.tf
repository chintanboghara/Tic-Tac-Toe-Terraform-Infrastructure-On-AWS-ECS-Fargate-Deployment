variable "network_name" {
  type        = string
  description = "Name of the Docker network to connect the database container to"
}

variable "db_password" {
  type        = string
  description = "Password for the PostgreSQL database"
  sensitive   = true
}