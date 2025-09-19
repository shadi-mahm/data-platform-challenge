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

### 4. Generate Sample Data

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
## Production Considerations

### Why Hand-Written Consumers Are Not Production-Ready

The Python consumer in this project is designed for demonstration purposes. Here's why it's not suitable for production:

#### **1. Reliability Issues**

- **No Error Recovery**: Simple try-catch blocks don't handle complex failure scenarios
- **Manual Offset Management**: Risk of data loss or duplication during failures
- **No Circuit Breakers**: Can overwhelm downstream systems during issues
- **Single Point of Failure**: No redundancy or failover mechanisms

#### **2. Performance Limitations**

- **Single-Threaded Processing**: Cannot handle high-throughput scenarios
- **Memory Management**: No built-in backpressure or memory optimization

#### **3. Operational Complexity**

- **Manual Scaling**: No automatic scaling based on lag or load
- **Monitoring Gaps**: Limited metrics and observability
- **Configuration Management**: Hard-coded values and poor configuration handling
- **Deployment Complexity**: Manual container management and updates

### Production-Ready Alternatives

#### **1. Kafka Connect**

**Benefits:**

- **Built-in Fault Tolerance**: Automatic retries and error handling
- **Scalability**: Horizontal scaling with worker distribution
- **Schema Evolution**: Support for Avro, JSON Schema, and Protobuf
- **Monitoring**: Built-in JMX metrics and REST API

#### **2. Apache Spark Structured Streaming**

**Benefits:**

- **Exactly-Once Processing**: Guarantees no data duplication
- **Advanced Processing**: Complex transformations and aggregations
- **Auto-Scaling**: Dynamic resource allocation
- **State Management**: Stateful processing with checkpointing

#### **3. ClickHouse Kafka Table Engine**

**Benefits:**

- **Native Integration**: Direct Kafka consumption within ClickHouse
- **High Performance**: Optimized for ClickHouse's architecture
- **Automatic Processing**: No external consumer needed
- **Built-in Monitoring**: ClickHouse system tables for monitoring

### Schema Registry and Data Governance

One important component missing from this data pipeline is **Confluent Schema Registry** or similar schema management solutions. In production environments, schema management is crucial for data governance and evolution.

#### **Why Schema Registry Wasn't Included**

This demo project intentionally omits schema registry for simplicity and focus:

- **Demonstration Clarity**: Adding schema registry would complicate the setup without adding educational value for basic pipeline concepts
- **Simple Data Format**: Our events use basic JSON with fixed structure, making schema evolution less critical
- **Development Speed**: Schema registry setup requires additional infrastructure and configuration complexity
- **Learning Focus**: The primary goal is demonstrating Kafka-to-ClickHouse data flow, not schema management

#### **Production Schema Management Requirements**

In production environments, you should implement schema management for:

- **Data Evolution Support**

- **Schema Validation:**

- Automatic validation of incoming messages against registered schemas
- Prevention of incompatible schema changes
- Centralized schema repository for all teams

## Data Schema

### Events Table Structure

```sql
CREATE TABLE events (
    user_id String,              
    event_type LowCardinality(String), 
    timestamp DateTime64(3, 'UTC'),   
    session_id String,           
    device LowCardinality(String),     
    inserted_at DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree()
ORDER BY (timestamp, user_id)
PARTITION BY toYYYYMMDD(timestamp)
SETTINGS index_granularity = 8192;
```

### Sample Event Format

```json
{
  "user_id": "user_42",
  "event_type": "purchase",
  "timestamp": "2025-09-18T10:30:00Z",
  "session_id": "sess_789",
  "device": "mobile"
}
```

## Additional Resources

- [Strimzi Documentation](https://strimzi.io/docs/)
- [ClickHouse Documentation](https://clickhouse.com/docs/)
- [Kafka Best Practices](https://kafka.apache.org/documentation/#bestpractices)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Contributing

This project is designed for demonstration purposes. For production use cases, consider the alternatives mentioned in the production considerations section.

## License

This project is created for demonstration purposes as part of a technical assessment.

