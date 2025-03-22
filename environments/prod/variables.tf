variable "db_password" {
  type        = string
  description = "Password for the PostgreSQL database"
  sensitive   = true
}

variable "frontend_port" {
  type        = number
  default     = 80
  description = "Host port to map to the frontend container"
}