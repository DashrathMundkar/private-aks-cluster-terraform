# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying Azure Kubernetes Service (AKS) clusters with various networking and security configurations, along with Jenkins setup on Azure VMs.

## Project Structure

### [Private-AKS-Cluster](Private-AKS-Cluster/)
Terraform configuration for deploying a private AKS cluster with Azure Firewall and restricted egress.
- **Subdirectories:**
  - [`cluster/`](Private-AKS-Cluster/cluster/) - Private AKS cluster with user-defined routing, firewall integration, route tables, and vnet peering
  - [`Firewall/`](Private-AKS-Cluster/Firewall/) - Azure Firewall setup with application and network rules, private endpoint for API server access
  - [`Resources/`](Private-AKS-Cluster/Resources/) - Kubernetes manifests (NGINX, Gateway, VirtualService, internal load balancer)
- **Key Features:** Private API endpoint, Azure Firewall for egress control, network peering with firewall vnet, private endpoint for secure API access, strict egress rules for Docker Hub, Ubuntu updates, and Azure services

### [Public-AKS-Cluster](Public-AKS-Cluster/)
Terraform configuration for deploying a public AKS cluster with Istio service mesh.
- **Main Files:**
  - `main.tf` - Resource group and cluster module
  - `provider.tf` - Azure and Azure AD provider configuration
  - `variables.tf` - Input variables
  - `terraform.tfvars` - Environment variables
- **Subdirectories:**
  - [`cluster/`](Public-AKS-Cluster/cluster/) - AKS cluster definition, networking (vnet, subnet), and load balancer configuration
  - [`kubernetes/`](Public-AKS-Cluster/kubernetes/) - Kubernetes manifests for NGINX deployment, Istio Gateway, and VirtualService
  - [`Istio/`](Public-AKS-Cluster/Istio/) - Istio networking resources (Gateway, VirtualService, internal load balancer)
- **Key Features:** Public API endpoint, Azure CNI networking with Calico policy, system-assigned managed identity, automatic maintenance windows

### [Setup-Jenkins-on-VM](Setup-Jenkins-on-VM/)
Terraform configuration to deploy Jenkins on an Azure Virtual Machine.
- **Files:**
  - `main.tf` - Core Azure resources (vnet, subnet, NIC, NSG)
  - `vm.tf` - Virtual machine configuration with custom script extension
  - `variable.tf` - Input variables for resource configuration
  - `DEV.tfvars` - Development environment variables
  - `output.tf` - Output values (VM public IP)
  - `jenkins_setup.sh` - Bash script to install Java 21, Git, Maven, and Jenkins
- **Key Features:** Automated Jenkins installation, SSH key-based authentication, security group rules for SSH (22), HTTP (80), HTTPS (443), and Jenkins (8080)

### [resources](resources/)
Shared Kubernetes manifests for basic deployments.
- `nginx.yaml` - NGINX Deployment and Service
- `gateway.yaml` - Istio Gateway configuration
- `virtual-service.yaml` - Istio VirtualService with URI rewriting
- `internal-lb.yaml` - Internal load balancer for Istio ingress gateway
- `README.md` - Instructions for installing Istio and deploying NGINX

## Prerequisites

- Terraform >= 1.8.3
- Azure CLI configured with valid credentials
- `kubectl` and `helm` installed locally
- SSH key pair for VM access
- Valid Azure subscription with appropriate permissions

## Deployment Order


### For Private AKS Cluster (with Firewall):
```bash
# Step 1: Deploy Firewall infrastructure
cd Private-AKS-Cluster/Firewall
terraform init
terraform apply -var-file="firewall.tfvars"

# Step 2: Deploy AKS Cluster
cd ../cluster
terraform init
terraform apply -var-file="terraform.tfvars"

# Step 3: Deploy Kubernetes resources
kubectl apply -f ../Resources/
```

### For Public AKS Cluster:
```bash
cd Public-AKS-Cluster
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### For Jenkins:
```bash
cd Setup-Jenkins-on-VM
terraform init
terraform apply -var-file="DEV.tfvars"
```

## Key Features

- **Public AKS:** Simple, internet-facing Kubernetes cluster with standard networking
- **Private AKS:** Secure, isolated cluster with Azure Firewall, private API endpoint, and restricted egress
- **Networking:** Virtual networks, subnets, network peering, network policies (Calico)
- **Service Mesh:** Istio integration for advanced traffic management and observability
- **Firewall Rules:** Docker Hub, Ubuntu packages, Azure services, and custom application rules
- **Jenkins:** Automated setup with Java 21, Maven, Git, and pre-configured agent tools

## Notes

- Update `subscription_id` in all `.tfvars` files before deployment
- For Private AKS, ensure firewall VNET and AKS VNET are created before establishing peering
- Use managed identities and RBAC for secure authentication
- Private endpoint DNS must be configured on the JumpBox VM for API server access
- Review firewall rules in `Private-AKS-Cluster/Firewall/firewall.tf` for your specific requirements

## Support

For more details on each component, refer to the README files in individual directories.