#!/bin/bash
set -e

echo "Starting to produce 100 records into Kafka topic 'events'..."

kubectl run -n kafka kafka-producer -ti --rm --restart=Never \
  --image=quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 -- \
  bash -c '
for i in $(seq 1 100); do
  echo "{\"user_id\":\"user_$i\", \
         \"event_type\":\"$(shuf -e login logout purchase view click -n 1)\", \
         \"timestamp\":\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \
         \"session_id\":\"sess_$((RANDOM%1000))\", \
         \"device\":\"$(shuf -e mobile desktop tablet -n 1)\"}"
done \
| bin/kafka-console-producer.sh \
    --bootstrap-server kafka-cluster-kafka-bootstrap:9092 \
    --topic events \
    --producer-property acks=all \
    --producer-property enable.idempotence=true
'

echo "Done!"