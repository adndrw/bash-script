#!/bin/bash

set -e

ZABBIX_SERVER="192.168.0.11"
ZABBIX_VERSION="6.0"

ZABBIX_RELEASE_URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb"
ZABBIX_RELEASE_DEB="/tmp/zabbix-release.deb"
ZABBIX_CONFIG="/etc/zabbix/zabbix_agentd.conf"

echo "=========================================="
echo "   Zabbix Agent ${ZABBIX_VERSION}"
echo "   Ubuntu 22.04"
echo "=========================================="
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this script with sudo."
    echo "Example: sudo ./install-zabbix-agent.sh"
    exit 1
fi

# Check Ubuntu 22.04
if ! grep -q 'VERSION_ID="22.04"' /etc/os-release; then
    echo "ERROR: This script is only for Ubuntu 22.04."
    exit 1
fi

# Input Zabbix Hostname
while true; do
    read -rp "Enter Zabbix Hostname: " ZABBIX_HOSTNAME

    if [ -n "$ZABBIX_HOSTNAME" ]; then
        break
    fi

    echo "Hostname cannot be empty."
done

echo ""
echo "Zabbix Hostname : ${ZABBIX_HOSTNAME}"
echo "Zabbix Server   : ${ZABBIX_SERVER}"
echo ""

# Download Zabbix repository
echo "[1/5] Downloading Zabbix repository..."

wget -q "${ZABBIX_RELEASE_URL}" -O "${ZABBIX_RELEASE_DEB}"

# Install Zabbix repository
echo "[2/5] Installing Zabbix repository..."

dpkg -i "${ZABBIX_RELEASE_DEB}"

# Update repository
echo "[3/5] Updating APT repository..."

apt update

# Install Zabbix Agent
echo "[4/5] Installing Zabbix Agent..."

apt install -y zabbix-agent

# Configure Zabbix Agent
echo "[5/5] Configuring Zabbix Agent..."

sed -i "s/^Server=.*/Server=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^Hostname=.*/Hostname=${ZABBIX_HOSTNAME}/" "${ZABBIX_CONFIG}"

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
echo "Hostname      : ${ZABBIX_HOSTNAME}"
echo "Zabbix Server : ${ZABBIX_SERVER}"
echo ""

echo "Configuration:"
echo "------------------------------------------"
grep -E '^(Server|ServerActive|Hostname)=' "${ZABBIX_CONFIG}"
echo "------------------------------------------"

echo ""
echo "Service Status:"
systemctl is-active zabbix-agent

echo ""
echo "=========================================="
echo "   DONE"
echo "=========================================="