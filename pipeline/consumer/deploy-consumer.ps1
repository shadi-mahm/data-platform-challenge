$ErrorActionPreference = "Stop"

Write-Host "Building and deploying Kafka-ClickHouse Consumer..."

Write-Host "Building Docker image..."
docker build -t "kafka-clickhouse-consumer:latest" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed"
    exit 1
}

Write-Host "Docker image built successfully"

Write-Host "Loading image into minikube..."
minikube image load "kafka-clickhouse-consumer:latest"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to load image into minikube"
    exit 1
}

Write-Host "Image loaded into minikube successfully"

Write-Host "Deploying to Kubernetes..."
kubectl apply -f consumer-deployment.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "Kubernetes deployment failed"
    exit 1
}

Write-Host "Deployment completed successfully!"