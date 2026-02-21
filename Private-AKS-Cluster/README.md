# Private AKS Cluster Deployment Guide

## Prerequisites
- Terraform installed
- Azure CLI configured with appropriate credentials
- SSH key pair for VM access
- `kubectl` and `helm` installed locally

## Step-by-Step Deployment Process

### Phase 1: Network Infrastructure

**Step 1: Deploy Firewall VNET**
- Create the Azure Firewall Virtual Network with required subnets
- Command: `cd Firewall && Only deploy firewall resource group, VNET and subnets`

**Step 2: Deploy AKS Cluster VNET**
- Create the AKS Virtual Network with required subnets
- Command: `cd cluster && Only deploy aks resource group, VNET and subnets`

**Step 3: Peer the Networks (Bidirectional)**
- Create virtual network peering between Firewall VNET and AKS VNET
- Command: Execute peering Terraform configurations
  - Firewall VNET → AKS VNET peering
  - AKS VNET → Firewall VNET peering (reciprocal)

### Phase 2: Firewall & Routing

**Step 4: Deploy Azure Firewall with Rules**
- Deploy the Azure Firewall resource with firewall policies
- Configure application rules for Docker, package managers, and Azure services
- Configure network rules for DNS, NTP, and API communications
- Verify firewall policy is attached in Azure Portal
- All rules defined in `firewall.tf` files

**Step 5: Enable Route Table Association**
- Deploy route table for AKS subnet
- Associate the route table with the AKS subnet
- Routes all traffic (0.0.0.0/0) through the firewall's private IP address
- Verify routes are correctly configured

### Phase 3: AKS Cluster & Private Access

**Step 6: Deploy AKS Cluster**
- Create the private AKS cluster (no public API server endpoint)
- Configure node pools
- Deploy cluster networking

**Step 7: Deploy Private Endpoint for API Server**
- Create a private endpoint on the Firewall VNET for the Kubernetes API server
- This allows JumpBox access to the private cluster API

### Phase 4: Access & Validation

**Step 8: Deploy JumpBox VM**
- Deploy an Ubuntu VM in the Firewall VNET with a public IP address from azure portal ui into the same resource group of `firewall-rg` and same vnet `firewall-vnet` and subnet of `pep-subnet`
- Install required tools: `azure-cli` and `kubectl` on ubuntu VM.

**Step 9: Configure API Server Access**
- SSH into the JumpBox VM
- Add the Kubernetes API server address to `/etc/hosts` file with the private endpoint IP address
- Example: `172.x.x.x kubernetes-api.privatelink.eastus.azmk8s.io` OR ``10.x.x.x kubernetes-api.privatelink.eastus.azmk8s.io`

**Step 10: Validate Firewall Rules**
- Deploy NGINX sample deployment to the AKS cluster using ` kubectl create deployment nginx --image=nginx --replicas=1`
- Verify pods are running (this confirms Docker pull rules are working).
- If pods are in pending status that is because system worker node has taint which need to be rmeoved.
- Go to the nodepool of system on kubernetes page and click on taint and remove the taint.
- Restart the deployment using `kubectl rollout restart deployment/nginx`
- Test Firewall restrictions:
  - `kubectl exec -it <nginx-pod> -- curl https://download.opensuse.org` ✅ Should work
  - `kubectl exec -it <nginx-pod> -- curl https://www.google.com` ❌ Should fail (not in whitelist)



# For latest information about ruels etc check this page https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic?pivots=system

  
### Phase 5: Use this for routing traffic to application using azure firewall public ip -> to istio -> pod service -> pod. 

**Step 11: Deploy Istio & Ingress Gateway**
- Install Istio service mesh for advanced routing
- Deploy Istio ingress gateway
- Configure virtual services and gateways

**Step 12: Validation Complete**
- All traffic routes through the firewall
- Docker images are pulled successfully via firewall rules
- External unrestricted traffic is blocked
- Private AKS cluster is secure and properly isolated

## Validation Checklist

- [] Firewall VNET created
- [ ] AKS VNET created
- [ ] Network peering established (bidirectional)
- [ ] Azure Firewall deployed with policy attached
- [ ] Route table created and associated
- [ ] AKS cluster created (private)
- [ ] Private endpoint deployed
- [ ] JumpBox VM deployed with public IP
- [ ] kubectl configured on JumpBox
- [ ] NGINX deployment running
- [ ] Docker pull rules verified
- [ ] Firewall blocking external traffic verified

## Troubleshooting

If connectivity issues occur:
1. Verify all peering connections are "Connected"
2. Check route table routes point to firewall private IP
3. Review firewall diagnostic logs
4. Verify AKS subnet is associated with route table
5. Check network security groups don't block traffic
6. Verify private endpoint DNS configuration












# Install Istio and deploy sample NGINX with Gateway

## Prerequisites

- `kubectl` configured to the target cluster
- `helm` (v3+) installed locally
- The YAML manifests in this folder: `nginx.yaml`, `gateway.yaml`, `virtual-service.yaml`

## Steps

1. Add and update the Istio Helm repository:

```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

2. Create the Istio system namespace and install core components:

```bash
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system
kubectl get pods -n istio-system
```

3. Install the Istio ingress gateway:

```bash
helm install istio-ingressgateway istio/gateway -n istio-system
kubectl get pods -n istio-system
```

4. Deploy the sample NGINX application and networking resources:

```bash
kubectl create namespace nginx
kubectl apply -f nginx.yaml
kubectl apply -f gateway.yaml
kubectl apply -f virtual-service.yaml
```

## Verify

- Confirm Istio pods are running: `kubectl get pods -n istio-system`
- Confirm ingress gateway is ready: `kubectl get svc -n istio-system`
- Check application pods/services in the `nginx` namespace: `kubectl get all -n nginx`

## Notes

- The README references `gateway.yaml` (not `gateway.yml`) — ensure the filename in this folder matches the command.
- If TLS is required on the gateway, add a `tls` block and a Kubernetes `Secret` containing certificates.
- If pods are `Pending`, check node capacity and network configuration.

## Troubleshooting

- If Helm install fails, run `helm repo update` then retry.
- If Istio pods crash, inspect logs: `kubectl logs <pod-name> -n istio-system`.

---
Small, quick guide to install Istio and deploy the sample NGINX + Gateway.