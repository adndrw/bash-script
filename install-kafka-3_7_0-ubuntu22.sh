#!/bin/bash

set -e

# =========================
# Install Java
# =========================
sudo apt update
sudo apt install -y default-jdk wget

java -version

# =========================
# Download Kafka 3.7.0
# =========================
wget https://archive.apache.org/dist/kafka/3.7.0/kafka_2.13-3.7.0.tgz

# Extract
tar -xzf kafka_2.13-3.7.0.tgz

# Move
sudo mv kafka_2.13-3.7.0 /usr/local/kafka

# =========================
# Generate Cluster ID
# =========================
KAFKA_CLUSTER_ID=$(/usr/local/kafka/bin/kafka-storage.sh random-uuid)

echo "Cluster ID: $KAFKA_CLUSTER_ID"

# =========================
# Configure KRaft
# =========================
sudo tee /usr/local/kafka/config/kraft/server.properties > /dev/null <<EOF
process.roles=broker,controller
node.id=1

controller.quorum.voters=1@127.0.0.1:9093

listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
advertised.listeners=PLAINTEXT://192.168.1.189:9092

listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT

log.dirs=/tmp/kraft-combined-logs

num.network.threads=1
num.io.threads=2

socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

log.retention.hours=24
log.segment.bytes=107374182
log.retention.check.interval.ms=300000

group.initial.rebalance.delay.ms=0
EOF

# =========================
# Format Storage
# =========================
/usr/local/kafka/bin/kafka-storage.sh format \
-t $KAFKA_CLUSTER_ID \
-c /usr/local/kafka/config/kraft/server.properties

# =========================
# Create Kafka Service
# =========================
sudo tee /etc/systemd/system/kafka.service > /dev/null <<EOF
[Unit]
Description=Apache Kafka Server (KRaft Mode)
Documentation=http://kafka.apache.org/documentation.html
After=network.target

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="KAFKA_HEAP_OPTS=-Xmx512M -Xms512M"

ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/kraft/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# =========================
# Reload Systemd
# =========================
sudo systemctl daemon-reload

# Enable Kafka
sudo systemctl enable kafka

# Start Kafka
sudo systemctl restart kafka

# =========================
# Check Status
# =========================
sleep 5
sudo systemctl status kafka --no-pager

# =========================
# Create Test Topic
# =========================
/usr/local/kafka/bin/kafka-topics.sh \
--create \
--topic testTopic \
--bootstrap-server localhost:9092 \
--partitions 1 \
--replication-factor 1

# =========================
# List Topics
# =========================
/usr/local/kafka/bin/kafka-topics.sh \
--list \
--bootstrap-server localhost:9092

echo "Kafka 3.7.0 KRaft installation completed successfully."