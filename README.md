# Data Platform - Kafka to ClickHouse Pipeline

A prototype data platform showcasing real-time event flow using Kafka and ClickHouse on Kubernetes.

## Architecture Overview

This project demonstrates a data pipeline architecture with the following components:

```plain
┌─────────────────┐    ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐
│     Producer    │───▶│    Kafka     │───▶│   Consumer   │───▶│   ClickHouse    │
│                 │    │              │    │   (Python)   │    │   Database      │
└─────────────────┘    └──────────────┘    └──────────────┘    └─────────────────┘
                                     
═══════════════════════════════════════════════════════════════════════════════════
                              Observability Layer                                   
═══════════════════════════════════════════════════════════════════════════════════
           ┌─────────────────┐                        ┌──────────────┐
           │   Prometheus    │                        │   Grafana    │
           │   (Metrics)     │                        │ (Dashboard)  │    
           └─────────────────┘                        └──────────────┘    
```

## Prerequisites

- **Kubernetes Cluster**: A running Kubernetes cluster (minikube, kind or k3s)
- **kubectl**: Kubernetes command-line tool configured to communicate with the cluster
- **Helm**: Package manager for Kubernetes (v3.x)
- **Docker**: For building and running containerized applications

### Verification Commands

```bash
kubectl cluster-info

helm version

kubectl get nodes
```

## Quick Start

### 1. Infrastructure Setup

The infrastructure setup installs all necessary components on Kubernetes:

```bash
cd infrastructure
./install-services.sh
```

**What this script does:**

- **Creates namespace**: Sets up dedicated `data` and `kafka` namespaces for isolation
- **Adds Helm repositories**: Configures Bitnami (for ClickHouse) and Strimzi (for Kafka)
- **Installs ClickHouse**: Single-node ClickHouse instance optimized for demonstration
- **Installs Kafka Operator**: Strimzi operator for managing Kafka
- **Creates Kafka Cluster**: Single-node Kafka with KRaft mode (no ZooKeeper)
- **Creates Kafka Topic**: Pre-configured `events` topic for the pipeline

### 2. Database Schema Setup

Create the ClickHouse database schema:

```bash
cd pipeline/schema
./create-clickhouse-schema.sh
```

**What this script does:**

- **Creates Database**: Sets up `bitpin` database in ClickHouse
- **Creates Events Table**: Optimized table structure with:
  - `ReplacingMergeTree` engine for deduplication
  - Time-based partitioning for query performance
  - Appropriate data types for each field

### 3. Deploy Consumer Application

Deploy the Python consumer that processes Kafka messages:

```bash
cd pipeline/consumer
./deploy-consumer.sh
```

**What this script does:**

- **Builds Docker Image**: Creates container with Python consumer code
- **Deploys to Kubernetes**: Creates deployment with proper configuration
- **Sets Environment Variables**: Configures Kafka and ClickHouse connections

### 4. Generate Test Data

Produce sample events to test the pipeline:

```bash
cd pipeline/producer
./produce-events.sh
```

**What this script does:**

- **Generates 100 Events**: Creates realistic user events (login, purchase, view, etc.)
- **Publishes to Kafka**: Sends events to the `events` topic
- **Uses Kafka Console Producer**: Leverages built-in Kafka tools for reliability

### 5. Install Observability Stack

Add observability and visualization:

```bash
cd observability
./install-observability.sh
```

**What this script does:**

- **Installs Prometheus**: Metrics collection
- **Installs Grafana**: Data visualization and dashboards
- **Configures ServiceMonitors**: Automatic service discovery for monitoring

## Project Structure

```plain
data-platform-challenge/
├── infrastructure/           # Kubernetes infrastructure components
│   ├── install-services.sh   # Main infrastructure deployment script
│   ├── helm-values/          # Helm chart configurations
│   │   └── clickhouse-values.yaml
│   └── manifests/            # Kubernetes YAML manifests
│       ├── namespace.yaml
│       ├── kafka-cluster.yaml
│       └── events-topic.yaml
├── pipeline/                 # Data pipeline components
│   ├── consumer/             # Python Kafka consumer
│   │   ├── consumer.py       # Main consumer application
│   │   ├── Dockerfile        # Container image definition
│   │   ├── requirements.txt  # Python dependencies
│   │   ├── consumer-deployment.yaml  # Kubernetes deployment
│   │   └── deploy-consumer.sh        # Deployment script
│   ├── producer/             # Event generation
│   │   └── produce-events.sh         # Event producer script
│   └── schema/               # Database schema creation
│       └── create-clickhouse-schema.sh
├── observability/            # Observability and visualization
│   ├── install-observability.sh
│   └── manifests/
│       ├── namespace.yaml
│       └── clickhouse-dashboard-configmap.yaml
└── docs/                     # Additional documentation
```

## Technology Selection & Rationale

### Core Technologies

#### **Apache Kafka with Strimzi Operator**

- **Why Strimzi over Bitnami**: Strimzi is the CNCF-recommended operator for Kafka on Kubernetes, while Bitnami is moving toward paid enterprise solutions
- **KRaft Mode**: Uses Kafka's native consensus protocol instead of ZooKeeper for simpler operation
- **Single Node**: Sufficient for demonstration purposes while maintaining production-like architecture

#### **ClickHouse Database**

- **Analytical Workloads**: Optimized for OLAP queries on time-series data
- **Compression**: Excellent compression ratios for event data storage
- **Single Node**: Easier to demonstrate and manage in development environments
- **ReplacingMergeTree**: Provides automatic deduplication of events

#### **Python Consumer**

- **Development Speed**: Rapid prototyping and easier debugging
- **Rich Ecosystem**: Extensive libraries for data processing
- **Demonstration Focus**: More readable and maintainable for showcasing concepts

#### **Bash Scripts**

- **Cross-Platform Compatibility**: Universal support across Unix-like systems
- **Kubernetes Integration**: Seamless kubectl and helm command execution  

## Monitoring and Verification

### Check Infrastructure Status

```bash
# Verify all pods are running
kubectl get pods -n data
kubectl get pods -n kafka

# Check Kafka cluster status
kubectl get kafka -n kafka

# Verify ClickHouse is accessible
kubectl port-forward -n data svc/clickhouse 8123:8123
# Then access http://localhost:8123/play (clickhouse playground) in browser
```

### Monitor Data Flow

```bash
# Check consumer logs
kubectl logs -n kafka deployment/kafka-clickhouse-consumer -f

# Verify data in ClickHouse
kubectl exec -n data svc/clickhouse -- clickhouse-client --user default --password clickhouse123 --query "SELECT COUNT(*) FROM bitpin.events"

# Check Kafka topic details
kubectl exec -n kafka svc/kafka-cluster-kafka-brokers -- bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic events```

### Observability Stack

If you installed the observability stack:

```bash
# Access Grafana dashboard
kubectl port-forward -n observability svc/prometheus-grafana 3000:80
# Username: admin, Password: prom-operator

# Access Prometheus
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 3001:9090
```
