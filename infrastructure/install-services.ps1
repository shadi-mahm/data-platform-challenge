$ErrorActionPreference = "Stop"

Write-Host "Installing BitPin Data Platform Infrastructure..."

Write-Host "Applying namespace..."
kubectl apply -f manifests/namespace.yaml

Write-Host "Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add strimzi https://strimzi.io/charts/
helm repo update

Write-Host "Installing ClickHouse single-node..."
helm upgrade --install clickhouse bitnami/clickhouse `
  --namespace data `
  -f helm-values/clickhouse-values.yaml

Write-Host "Adding clickhouse metrics configmap..."
kubectl apply -f manifests/clickhouse-dashboard-configmap.yaml

Write-Host "Installing Kafka operator..."
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator -n kafka

Write-Host "Creating Kafka cluster..."
kubectl apply -f manifests/kafka-cluster.yaml

Write-Host "Creating Kafka events topic..."
kubectl apply -f manifests/events-topic.yaml