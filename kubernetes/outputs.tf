output "namespace" {
  description = "Kubernetes namespace created"
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "service_info" {
  description = "Service access information"
  value       = {
    name      = kubernetes_service.nginx.metadata[0].name
    namespace = kubernetes_service.nginx.metadata[0].namespace
    node_port = kubernetes_service.nginx.spec[0].port[0].node_port
  }
}

output "access_instructions" {
  description = "Instructions to access the application"
  value       = <<-EOT
  To access the Kubernetes application:
  1. kubectl port-forward -n terraform-app svc/nginx-service 8080:80
  2. Open: http://localhost:8080
  OR
  1. Access directly via NodePort: http://localhost:30080
  EOT
}

output "cluster_info" {
  description = "Kubernetes cluster information"
  value       = "Cluster: terraform-cluster | Nodes: k3d cluster"
}
