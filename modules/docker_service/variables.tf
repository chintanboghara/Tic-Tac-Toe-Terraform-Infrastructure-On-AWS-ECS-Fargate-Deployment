variable "container_name" {
  type        = string
  description = "Name of the Docker container."
}

variable "image" {
  type        = string
  description = "Docker image to deploy."
}

variable "ports" {
  type = list(object({
    internal = number
    external = number
  }))
  description = "List of port mappings for the container."
  default     = []
}

variable "env_vars" {
  type        = list(string)
  description = "List of environment variables in KEY=VALUE format."
  default     = []
}

# Accept either network name or network ID.
variable "network_name" {
  type        = string
  description = "Optional Docker network name to attach."
  default     = ""
}

variable "network_id" {
  type        = string
  description = "Optional Docker network ID to attach."
  default     = ""
}
