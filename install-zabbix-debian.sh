#!/bin/bash

set -e

ZABBIX_SERVER="192.168.0.11"
ZABBIX_VERSION="6.0"

ZABBIX_RELEASE_URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian13_all.deb"
ZABBIX_RELEASE_DEB="/tmp/zabbix-release.deb"
ZABBIX_CONFIG="/etc/zabbix/zabbix_agentd.conf"

echo "=========================================="
echo "   Zabbix Agent ${ZABBIX_VERSION}"
echo "   Debian Forky / Sid"
echo "=========================================="
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this script with sudo."
    echo ""
    echo "Example:"
    echo "sudo ./install-zabbix-agent.sh"
    exit 1
fi

# Check Debian
if ! grep -q "Debian" /etc/os-release; then
    echo "ERROR: This script is only for Debian."
    exit 1
fi

# ==========================================
# INPUT ZABBIX HOSTNAME
# ==========================================

while true; do
    echo ""
    read -r -p "Enter Zabbix Hostname: " ZABBIX_HOSTNAME < /dev/tty

    ZABBIX_HOSTNAME="$(echo "${ZABBIX_HOSTNAME}" | xargs)"

    if [ -z "${ZABBIX_HOSTNAME}" ]; then
        echo "ERROR: Hostname cannot be empty."
        continue
    fi

    if [[ ! "${ZABBIX_HOSTNAME}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "ERROR: Invalid hostname."
        echo "Allowed characters: a-z A-Z 0-9 . _ -"
        continue
    fi

    break
done

echo ""
echo "=========================================="
echo "Installation Configuration"
echo "=========================================="
echo "Zabbix Hostname : ${ZABBIX_HOSTNAME}"
echo "Zabbix Server   : ${ZABBIX_SERVER}"
echo "Zabbix Version   : ${ZABBIX_VERSION}"
echo "=========================================="
echo ""

read -r -p "Continue installation? [y/N]: " CONFIRM < /dev/tty

if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# ==========================================
# DOWNLOAD ZABBIX REPOSITORY
# ==========================================

echo ""
echo "[1/5] Downloading Zabbix repository..."

wget -q "${ZABBIX_RELEASE_URL}" -O "${ZABBIX_RELEASE_DEB}"

# ==========================================
# INSTALL REPOSITORY
# ==========================================

echo "[2/5] Installing Zabbix repository..."

dpkg -i "${ZABBIX_RELEASE_DEB}"

# ==========================================
# UPDATE APT
# ==========================================

echo "[3/5] Updating APT repository..."

apt update

# ==========================================
# INSTALL ZABBIX AGENT
# ==========================================

echo "[4/5] Installing Zabbix Agent..."

apt install -y zabbix-agent

# ==========================================
# CONFIGURE ZABBIX AGENT
# ==========================================

echo "[5/5] Configuring Zabbix Agent..."

sed -i "s/^Server=.*/Server=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER}/" "${ZABBIX_CONFIG}"
sed -i "s/^Hostname=.*/Hostname=${ZABBIX_HOSTNAME}/" "${ZABBIX_CONFIG}"

# ==========================================
# ENABLE & START SERVICE
# ==========================================

systemctl enable zabbix-agent
systemctl restart zabbix-agent

# Cleanup
rm -f "${ZABBIX_RELEASE_DEB}"

# ==========================================
# VERIFY
# ==========================================

echo ""
echo "=========================================="
echo "   Installation Completed"
echo "=========================================="
echo ""
echo "Configuration:"
echo "------------------------------------------"

grep -E '^(Server|ServerActive|Hostname)=' "${ZABBIX_CONFIG}"

echo "------------------------------------------"
echo ""

if systemctl is-active --quiet zabbix-agent; then
    echo "Zabbix Agent : RUNNING"
else
    echo "Zabbix Agent : FAILED"
    echo ""
    systemctl --no-pager -l status zabbix-agent
    echo ""
    journalctl -u zabbix-agent --no-pager -n 30
    exit 1
fi

echo ""
echo "=========================================="
echo "   DONE"
echo "=========================================="