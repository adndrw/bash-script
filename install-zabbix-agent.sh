#!/bin/bash

set -e

ZABBIX_SERVER="192.168.0.11"
ZABBIX_VERSION="6.0-4+ubuntu22.04"
ZABBIX_DEB="zabbix-release_${ZABBIX_VERSION}_all.deb"
ZABBIX_URL="https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/${ZABBIX_DEB}"

echo "======================================"
echo " Installing Zabbix Agent 6.0"
echo "======================================"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Get hostname
HOSTNAME=$(hostname)

echo "[1/5] Hostname : ${HOSTNAME}"
echo "[2/5] Zabbix Server : ${ZABBIX_SERVER}"

# Download Zabbix repository
echo "[3/5] Downloading Zabbix repository..."
wget -q "${ZABBIX_URL}" -O "/tmp/${ZABBIX_DEB}"

# Install repository
echo "[4/5] Installing Zabbix repository..."
dpkg -i "/tmp/${ZABBIX_DEB}"

# Update repository
apt update -y

# Install Zabbix Agent
echo "Installing Zabbix Agent..."
apt install -y zabbix-agent

# Configure Zabbix Agent
echo "Configuring Zabbix Agent..."

CONFIG="/etc/zabbix/zabbix_agentd.conf"

sed -i "s/^Server=.*/Server=${ZABBIX_SERVER}/" "${CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER}/" "${CONFIG}"
sed -i "s/^Hostname=.*/Hostname=${HOSTNAME}/" "${CONFIG}"

# If configuration doesn't exist, append it
grep -q "^Server=" "${CONFIG}" || echo "Server=${ZABBIX_SERVER}" >> "${CONFIG}"
grep -q "^ServerActive=" "${CONFIG}" || echo "ServerActive=${ZABBIX_SERVER}" >> "${CONFIG}"
grep -q "^Hostname=" "${CONFIG}" || echo "Hostname=${HOSTNAME}" >> "${CONFIG}"

# Enable and restart service
echo "[5/5] Starting Zabbix Agent..."

systemctl enable zabbix-agent
systemctl restart zabbix-agent

# Check service
echo ""
echo "======================================"
echo " Zabbix Agent Status"
echo "======================================"

systemctl --no-pager --full status zabbix-agent

echo ""
echo "======================================"
echo " Installation Complete"
echo "======================================"
echo "Hostname       : ${HOSTNAME}"
echo "Zabbix Server   : ${ZABBIX_SERVER}"
echo "Service         : zabbix-agent"
echo "======================================"