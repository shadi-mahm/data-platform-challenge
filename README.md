# Data Platform - Kafka to ClickHouse Pipeline

A demonstration data platform showcasing real-time event flow using Kafka and ClickHouse on Kubernetes.

## Architecture Overview

This project demonstrates a data pipeline architecture with the following components:

```plain
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Event Source  │───▶│    Kafka     │───▶│   ClickHouse    │
│   (Producer)    │    │              │    │   Database      │
└─────────────────┘    └──────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────┐
                       │   Consumer   │
                       │   (Python)   │
                       └──────────────┘
```

## Prerequisites

- **Kubernetes Cluster**: A running Kubernetes cluster (minikube, kind or k3s)
- **kubectl**: Kubernetes command-line tool configured to communicate with the cluster
- **Helm**: Package manager for Kubernetes (v3.x)
- **PowerShell**: For running Windows-compatible scripts
- **Docker**: For building and running containerized applications

### Verification Commands

```bash
# Verify kubectl connection
kubectl cluster-info

# Verify Helm installation
helm version

# Check available nodes
kubectl get nodes
```