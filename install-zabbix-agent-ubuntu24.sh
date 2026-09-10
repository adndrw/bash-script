#!/bin/bash

set -e

ZABBIX_SERVER="192.168.0.11"
ZABBIX_VERSION="6.0"

ZABBIX_RELEASE_URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb"
ZABBIX_RELEASE_DEB="/tmp/zabbix-release.deb"
ZABBIX_CONFIG="/etc/zabbix/zabbix_agentd.conf"

echo "=========================================="
echo "   Install Zabbix Agent ${ZABBIX_VERSION}"
echo "   Ubuntu 24.04"
echo "=========================================="

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script with sudo."
    echo "Example: sudo ./install-zabbix-agent.sh"
    exit 1
fi

# Check OS
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "ERROR: This script is for Ubuntu."
    exit 1
fi

if ! grep -q 'VERSION_ID="24.04"' /etc/os-release; then
    echo "ERROR: This script is specifically for Ubuntu 24.04."
    exit 1
fi

HOSTNAME=$(hostname)

echo ""
echo "Hostname       : ${HOSTNAME}"
echo "Zabbix Server  : ${ZABBIX_SERVER}"
echo "Zabbix Version : ${ZABBIX_VERSION}"
echo ""

# Remove old/wrong Zabbix repository
echo "[1/6] Removing old Zabbix repository..."

rm -f /etc/apt/sources.list.d/zabbix.list

# Download Zabbix repository
echo "[2/6] Downloading Zabbix repository..."

wget -q "${ZABBIX_RELEASE_URL}" -O "${ZABBIX_RELEASE_DEB}"

# Install Zabbix repository
echo "[3/6] Installing Zabbix repository..."

dpkg -i "${ZABBIX_RELEASE_DEB}"

# Update repository
echo "[4/6] Updating APT repository..."

apt update

# Install Zabbix Agent
echo "[5/6] Installing Zabbix Agent..."

apt install -y zabbix-agent

# Configure Zabbix Agent
echo "[6/6] Configuring Zabbix Agent..."

sed -i "s/^Server=.*/Server=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^Hostname=.*/Hostname=${HOSTNAME}/" "${ZABBIX_CONFIG}"

# Enable and restart service
systemctl enable zabbix-agent
systemctl restart zabbix-agent

# Cleanup
rm -f "${ZABBIX_RELEASE_DEB}"

echo ""
echo "=========================================="
echo "   Installation Completed"
echo "=========================================="
echo ""
echo "Hostname      : ${HOSTNAME}"
echo "Zabbix Server : ${ZABBIX_SERVER}"
echo ""

echo "Configuration:"
grep -E '^(Server|ServerActive|Hostname)=' "${ZABBIX_CONFIG}"

echo ""
echo "Service status:"
systemctl --no-pager --full status zabbix-agent

echo ""
echo "=========================================="
echo "   DONE"
echo "=========================================="