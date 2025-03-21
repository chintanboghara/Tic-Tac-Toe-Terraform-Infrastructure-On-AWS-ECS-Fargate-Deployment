variable "db_password" {
  type      = string
  sensitive = true
  description = "Password for the MySQL root user"
}

variable "db_user" {
  type    = string
  default = "root"
  description = "MySQL user"
}

variable "db_name" {
  type    = string
  default = "mydb"
  description = "Name of the MySQL database"
}

variable "frontend_port" {
  type    = number
  default = 8080
  description = "Port on the host to expose the frontend"
}