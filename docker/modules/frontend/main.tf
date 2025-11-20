resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# Create HTML directory
resource "null_resource" "create_html_dir" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "New-Item -ItemType Directory -Force -Path html"
    interpreter = ["PowerShell", "-Command"]
  }
}

# Create custom HTML file
resource "local_file" "index_html" {
  filename = abspath("./html/index.html")
  content  = <<-EOT
  <!DOCTYPE html>
  <html>
  <head>
      <title>Terraform Docker App</title>
      <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          .container { max-width: 800px; margin: 0 auto; }
          .service { padding: 15px; margin: 10px 0; border-left: 4px solid #4CAF50; background: #f9f9f9; }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>Terraform Docker Application</h1>
          <p>This 3-tier application was deployed using Terraform.</p>
          
          <div class="service">
              <h3>Frontend Service</h3>
              <p>NGINX web server running on port 8080</p>
          </div>
          
          <div class="service">
              <h3>Backend Service</h3>
              <p>Python Flask API running on port 5000</p>
              <p>Health check: <a href="http://localhost:5000/health" target="_blank">/health</a></p>
          </div>
          
          <div class="service">
              <h3>Database Service</h3>
              <p>PostgreSQL database running in Docker network</p>
          </div>
      </div>
  </body>
  </html>
  EOT

  depends_on = [null_resource.create_html_dir]
}

resource "docker_container" "frontend" {
  name  = "app-frontend"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    container_path = "/usr/share/nginx/html"
    host_path      = abspath("./html")
  }

  depends_on = [local_file.index_html]
}

output "frontend_port" {
  value = "8080"
}
