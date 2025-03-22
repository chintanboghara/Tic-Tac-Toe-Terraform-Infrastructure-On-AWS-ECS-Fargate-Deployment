variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "sample-app-container"
}

variable "image" {
  description = "Docker image to deploy"
  type        = string
  default     = "nginx:latest"
}

variable "ports" {
  description = "Map of container ports to host ports"
  type        = map(number)
  default     = {
    "80" = 8080
  }
}
