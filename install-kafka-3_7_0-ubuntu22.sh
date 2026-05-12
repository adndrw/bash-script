#!/bin/bash

sudo apt update
sudo apt install -y default-jdk wget

java -version

# Download Kafka 3.7.0
wget https://archive.apache.org/dist/kafka/3.7.0/kafka_2.12-3.7.0.tgz

# Extract
tar xvf kafka_2.12-3.7.0.tgz

# Move to /usr/local
sudo mv kafka_2.12-3.7.0 /usr/local/kafka

# Create Zookeeper service
echo "[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
ExecStop=/usr/local/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/zookeeper.service

# Create Kafka service
echo '[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="KAFKA_HEAP_OPTS=-Xmx512M -Xms512M"
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/kafka.service

# Configure Kafka listener
sudo sed -i 's/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/0.0.0.0:9092/' /usr/local/kafka/config/server.properties

sudo sed -i 's/#advertised.listeners=PLAINTEXT:\/\/your.host.name:9092/advertised.listeners=PLAINTEXT:\/\/192.168.1.189:9092/' /usr/local/kafka/config/server.properties

# Reload systemd
sudo systemctl daemon-reload

# Enable services
sudo systemctl enable zookeeper
sudo systemctl enable kafka

# Start services
sudo systemctl restart zookeeper
sudo systemctl restart kafka

# Check status
sudo systemctl status zookeeper --no-pager
sudo systemctl status kafka --no-pager

# Create test topic
/usr/local/kafka/bin/kafka-topics.sh \
--create \
--bootstrap-server localhost:9092 \
--replication-factor 1 \
--partitions 1 \
--topic testTopic