output "frontend_url" {
  description = "URL to access the frontend"
  value       = "http://localhost:8080"
}

output "backend_url" {
  description = "URL to access the backend API"
  value       = "http://localhost:5000/health"
}

output "application_status" {
  description = "Application deployment status"
  value       = "Docker infrastructure deployed successfully!"
}
