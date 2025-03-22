provider "docker" {}

module "network" {
  source = "../../modules/network"
}

module "database" {
  source       = "../../modules/database"
  network_name = module.network.name
  db_password  = var.db_password
}

module "backend" {
  source       = "../../modules/backend"
  network_name = module.network.name
  db_host      = module.database.host
  db_password  = var.db_password
}

module "frontend" {
  source       = "../../modules/frontend"
  network_name = module.network.name
  backend_url  = module.backend.url
  host_port    = var.frontend_port
}