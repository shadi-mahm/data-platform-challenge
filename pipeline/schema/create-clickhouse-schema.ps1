
Write-Host "Creating ClickHouse schema for events..."

$CLICKHOUSE_HOST = "clickhouse"  # Service name in Kubernetes
$CLICKHOUSE_PORT = "9000"
$CLICKHOUSE_USER = "default"
$CLICKHOUSE_PASSWORD = "clickhouse123"

$schemaSql = @"
CREATE DATABASE IF NOT EXISTS bitpin;

USE bitpin;

CREATE TABLE IF NOT EXISTS events (
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
"@

try {
    Write-Host "Connecting to ClickHouse and creating schema..."
    
    kubectl run -n data clickhouse-client --rm -i --restart=Never `
        --image=clickhouse/clickhouse-server:latest `
        -- clickhouse-client `
        --host=$CLICKHOUSE_HOST `
        --port=$CLICKHOUSE_PORT `
        --user=$CLICKHOUSE_USER `
        --password=$CLICKHOUSE_PASSWORD `
        --multiquery `
        --query="$schemaSql"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully created ClickHouse schema!"
    }
    else {
        Write-Host "Error: Failed to create schema with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}