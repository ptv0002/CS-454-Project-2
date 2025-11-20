resource "docker_image" "backend" {
  name         = "python:3.11-alpine"
  keep_locally = true
}

# Create a simple Python script file for our backend
resource "local_file" "backend_script" {
  filename = abspath("./app.py")
  content  = <<-EOT
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "backend"})

@app.route("/data")
def data():
    return jsonify({"message": "Hello from Backend API!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOT
}

resource "docker_container" "backend" {
  name  = "app-backend"
  image = docker_image.backend.image_id

  env = [
    "DB_HOST=${var.db_host}",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "PYTHONUNBUFFERED=1"
  ]

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 5000
    external = 5000
  }

  # Mount the script and install dependencies
  volumes {
    container_path = "/app"
    host_path      = abspath("./")
  }

  command = [
    "sh", "-c",
    "pip install flask && python /app/app.py"
  ]

  depends_on = [docker_image.backend, local_file.backend_script]
}

output "backend_host" {
  value = "app-backend"
}

output "backend_port" {
  value = "5000"
}
