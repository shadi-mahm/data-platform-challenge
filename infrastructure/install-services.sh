#!/bin/bash
set -e

echo "Installing BitPin Data Platform Infrastructure..."

echo "Applying namespace..."
kubectl apply -f manifests/namespace.yaml

echo "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add strimzi https://strimzi.io/charts/
helm repo update

echo "Installing ClickHouse single-node..."
helm upgrade --install clickhouse bitnami/clickhouse --namespace data -f helm-values/clickhouse-values.yaml

echo "Installing Kafka operator..."
helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator -n kafka

echo "Creating Kafka..."
kubectl apply -f manifests/kafka-cluster.yaml

echo "Creating Kafka events topic..."
kubectl apply -f manifests/events-topic.yaml