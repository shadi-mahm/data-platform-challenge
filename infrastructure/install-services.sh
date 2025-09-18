#!/bin/bash
set -e

echo "Installing BitPin Data Platform Infrastructure..."

echo "Applying namespace..."
kubectl apply -f manifests/namespace.yaml

echo "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "Installing ClickHouse single-node..."
helm upgrade --install clickhouse bitnami/clickhouse --namespace data -f helm-values/clickhouse-values.yaml

echo "Installing Kafka single-node..."
helm upgrade --install kafka bitnami/kafka --namespace kafka -f helm-values/kafka-values.yaml