terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "terraform-app"
  }
}

# Enhancement: ConfigMap for custom nginx page
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-index-html"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    "index.html" = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
        <title>K8s Terraform App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 800px; margin: 0 auto; }
            .info-box { padding: 20px; margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Kubernetes Terraform Application</h1>
            <p>This application is running on Kubernetes managed by Terraform!</p>
            
            <div class="info-box">
                <h3>Application Details</h3>
                <p><strong>Namespace:</strong> terraform-app</p>
                <p><strong>Pods:</strong> 2 replicas running</p>
                <p><strong>Service Type:</strong> NodePort</p>
                <p><strong>Access Port:</strong> 30080</p>
            </div>
        </div>
    </body>
    </html>
    EOT
  }
}

# Single nginx deployment with ConfigMap
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:alpine"
          name  = "nginx"
          port {
            container_port = 80
          }

          volume_mount {
            name       = "html-volume"
            mount_path = "/usr/share/nginx/html"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "html-volume"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Service to expose nginx
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.nginx.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}
