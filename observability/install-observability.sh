#!/bin/bash
set -e

echo "Installing BitPin Data Platform Observability..."

echo "Applying observability namespace..."
kubectl apply -f manifests/namespace.yaml

echo "Adding Prometheus Community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Installing kube-prometheus-stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace observability -f helm-values/prometheus-values.yaml

echo "Observability stack deployment completed."