#**Project Overview**
****
This project shows infrastructure-as-code using Terraform to deploy applications on both Docker and Kubernetes environments. They have a 3-tier application arechitecture with a frontend, backend, and a database.

#**Project Structure**
****
For the docker project we have the following files that take care of the logic and deployment
1. main.tf
2. variables.tf
3. outputs.tf
4. modules/frontend/
5. modules/backend/
6. modules/database/

For the kubernetes we have the following files
1. main.tf
2. outputs.tf

#**Docker Infrastructure**
#**Deployment**
cd docker
terraform init
terraform apply

#**URL**
Frontend: http://localhost:8080
Backend API: http://localhost:5000/health

#**Kubernetes Infrastructure**
#**Deployment**
k3d cluster create terraform-cluster --port "8080:30080@loadbalancer"
cd kubernetes
terraform init
terraform apply

#**Access**
kubectl port-forward -n terraform-app svc/nginx-service 8080:80

#**Technology Used**
Terraform - Infrastructure as Code
Docker - Containerization
Kubernetes (k3d) - Container orchestration
Nginx - Web server
Python/Flask - Backend API
PostgreSQL - Database

#**Cleanup**
#**Docker Cleanup**
cd docker
terraform destroy

#**Kubernetes Cleanup** 
cd ../kubernetes
terraform destroy
k3d cluster delete terraform-cluster
