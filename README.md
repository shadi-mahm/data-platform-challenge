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
- **PowerShell**: For running Windows-compatible scripts
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

- **Creates namespace**: Sets up edicated `data` and `kafka` namespaces for isolation
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

