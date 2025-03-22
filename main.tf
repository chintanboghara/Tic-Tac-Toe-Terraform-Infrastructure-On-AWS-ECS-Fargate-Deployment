terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }

  # Optional backend configuration for remote state
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "docker-terraform-project/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "docker" {
  # Docker provider configuration (usually auto-detected on local machines)
}

module "app_container" {
  source         = "./modules/docker_container"
  container_name = var.container_name
  image          = var.image
  ports          = var.ports
}
