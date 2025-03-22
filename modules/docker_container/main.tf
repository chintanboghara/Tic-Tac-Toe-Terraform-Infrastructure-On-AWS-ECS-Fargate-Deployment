resource "docker_image" "app" {
  name = var.image
}

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.latest
  ports {
    internal = tonumber(keys(var.ports)[0])
    external = var.ports[keys(var.ports)[0]]
  }
  
  # If more ports or configurations are needed, consider using dynamic blocks
  # or extending the variable schema.
}
