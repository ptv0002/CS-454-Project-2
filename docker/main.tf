terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

provider "local" {}

provider "null" {}

# Create custom network
resource "docker_network" "app_network" {
  name     = "app-network"
  driver   = "bridge"
  internal = false
}

# Module calls
module "database" {
  source = "./modules/database"

  providers = {
    docker = docker
  }

  network_name = docker_network.app_network.name
  db_password  = "mysecurepassword123"
  db_name      = "appdb"
  db_user      = "appuser"
}

module "backend" {
  source = "./modules/backend"

  providers = {
    docker = docker
    local  = local
  }

  network_name = docker_network.app_network.name
  db_host      = module.database.db_host
  db_password  = "mysecurepassword123"
  db_name      = "appdb"
  db_user      = "appuser"
}

module "frontend" {
  source = "./modules/frontend"

  providers = {
    docker = docker
    local  = local
  }

  network_name = docker_network.app_network.name
  backend_host = module.backend.backend_host
}
