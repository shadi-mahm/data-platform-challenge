import json
import os
import clickhouse_connect
from datetime import datetime
from kafka import KafkaConsumer

def main():
    """Simple consumer that reads from Kafka and writes to ClickHouse."""

    kafka_servers = os.getenv(
        'KAFKA_BOOTSTRAP_SERVERS', 'kafka-cluster-kafka-bootstrap:9092')
    kafka_topic = os.getenv('KAFKA_TOPIC', 'events')
    clickhouse_host = os.getenv('CLICKHOUSE_HOST', 'clickhouse.data.svc.cluster.local')
    clickhouse_user = os.getenv('CLICKHOUSE_USER', 'default')
    clickhouse_password = os.getenv('CLICKHOUSE_PASSWORD', 'clickhouse123')
    clickhouse_database = os.getenv('CLICKHOUSE_DATABASE', 'bitpin')

    print("Starting Kafka to ClickHouse consumer...")

    consumer = KafkaConsumer(
        kafka_topic,
        bootstrap_servers=kafka_servers,
        value_deserializer=lambda x: json.loads(x.decode('utf-8')),
        auto_offset_reset='latest',
        enable_auto_commit=False
    )

    clickhouse = clickhouse_connect.get_client(
        host=clickhouse_host,
        username=clickhouse_user,
        password=clickhouse_password,
        database=clickhouse_database
    )

    print(
        f"Connected to Kafka topic '{kafka_topic}' and ClickHouse database '{clickhouse_database}'")

    for message in consumer:
        try:
            data = message.value
            timestamp = datetime.fromisoformat(
                data['timestamp'].replace('Z', '+00:00'))

            clickhouse.insert(
                table='events',
                data=[[
                    data['user_id'],
                    data['event_type'],
                    timestamp,
                    data['session_id'],
                    data['device']
                ]],
                column_names=['user_id', 'event_type',
                              'timestamp', 'session_id', 'device']
            )

            print(f"Inserted: {data['user_id']} - {data['event_type']}")

        except Exception as e:
            print(f"Error processing message: {e}")

if __name__ == "__main__":
    main()