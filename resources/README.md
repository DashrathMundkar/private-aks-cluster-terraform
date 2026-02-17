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