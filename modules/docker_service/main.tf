resource "docker_image" "service_image" {
  name         = var.image
  keep_locally = false
}

resource "docker_container" "service_container" {
  name  = var.container_name
  image = docker_image.service_image.name

  dynamic "ports" {
    for_each = var.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  # Attach container to specified network
  networks_advanced {
    name = var.network_name != "" ? var.network_name : null
    # If using network_id instead of name:
    # network_id = var.network_id
  }

  # Optional environment variables
  env = var.env_vars
}
