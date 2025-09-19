#!/bin/bash

echo "Building and deploying Kafka-ClickHouse Consumer..."

echo "Building Docker image..."
if ! docker build -t "kafka-clickhouse-consumer:latest" .; then
    echo "Docker build failed"
    exit 1
fi

echo "Docker image built successfully"

echo "Loading image into minikube..."
if ! minikube image load "kafka-clickhouse-consumer:latest"; then
    echo "Failed to load image into minikube"
    exit 1
fi

echo "Image loaded into minikube successfully!"

echo "Deploying to Kubernetes..."
if ! kubectl apply -f consumer-deployment.yaml; then
    echo -e "Kubernetes deployment failed"
    exit 1
fi

echo "Deployment completed successfully!"