variable "container_name" {
  description = "Name of the Docker container"
  type        = string
}

variable "image" {
  description = "Docker image to deploy"
  type        = string
}

variable "ports" {
  description = "Map of container ports to host ports"
  type        = map(number)
}
