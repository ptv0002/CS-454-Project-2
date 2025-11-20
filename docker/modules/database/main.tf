resource "docker_image" "postgres" {
  name         = "postgres:15-alpine"
  keep_locally = true
}

resource "docker_container" "database" {
  name  = "app-database"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  networks_advanced {
    name = var.network_name
  }

  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = abspath("./postgres-data")
  }
}

output "db_host" {
  value = "app-database"
}

output "db_port" {
  value = "5432"
}
