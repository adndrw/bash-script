#!/bin/bash

set -e

echo "=========================================="
echo " Docker Installer for Ubuntu"
echo "=========================================="

# Cek apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Silakan jalankan script ini menggunakan sudo."
    exit 1
fi

echo "[1/8] Update package..."
apt-get update

echo "[2/8] Install dependency..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "[3/8] Membuat keyring Docker..."
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo "[4/8] Menambahkan repository Docker..."

ARCH=$(dpkg --print-architecture)
CODENAME=$(source /etc/os-release && echo "$VERSION_CODENAME")

echo \
"deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
> /etc/apt/sources.list.d/docker.list

echo "[5/8] Update repository..."
apt-get update

echo "[6/8] Install Docker..."
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "[7/8] Enable Docker Service..."
systemctl enable docker
systemctl start docker

echo "[8/8] Verifikasi..."
docker --version
docker compose version

echo ""
echo "=========================================="
echo " Docker berhasil diinstall!"
echo "=========================================="
echo ""

# Tambahkan user saat ini ke group docker
REAL_USER=${SUDO_USER:-$USER}

if id "$REAL_USER" &>/dev/null; then
    usermod -aG docker "$REAL_USER"
    echo "User '$REAL_USER' telah ditambahkan ke group docker."
    echo "Silakan logout/login kembali atau jalankan:"
    echo ""
    echo "newgrp docker"
    echo ""
fi

docker run hello-world

echo ""
echo "Selesai."