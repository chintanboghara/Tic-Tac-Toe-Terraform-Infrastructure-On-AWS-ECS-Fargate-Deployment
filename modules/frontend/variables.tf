variable "network_name" {
  type        = string
  description = "Name of the Docker network to connect the frontend container to"
}

variable "backend_url" {
  type        = string
  description = "URL of the backend service to fetch data from"
}

variable "host_port" {
  type        = number
  description = "Host port to map to the frontend container's port 80"
}