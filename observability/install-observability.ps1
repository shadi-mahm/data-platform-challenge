$ErrorActionPreference = "Stop"

Write-Host "Installing BitPin Data Platform Observability..."

Write-Host "Applying observability namespace..."
kubectl apply -f manifests/namespace.yaml

Write-Host "Adding Prometheus Community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Write-Host "Installing kube-prometheus-stack..."
helm install prometheus prometheus-community/kube-prometheus-stack `
  --namespace observability

Write-Host "Observability stack deployment completed."