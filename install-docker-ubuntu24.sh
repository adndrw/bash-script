#!/bin/bash
# =====================================================
# Script Install Docker & Docker Compose on Ubuntu 24.04
# Author : adndrw_
# Date   : 2026-10-06
# =====================================================

set -e

echo "====================================================="
echo " Docker & Docker Compose Installation"
echo " Ubuntu 24.04"
echo "====================================================="

echo
echo "=== [1/7] Update system packages ==="
sudo apt update -y

echo
echo "=== [2/7] Install required dependencies ==="
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo
echo "=== [3/7] Add Docker official GPG key ==="

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo
echo "=== [4/7] Add Docker official repository ==="

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

echo
echo "=== [5/7] Install Docker Engine & Docker Compose ==="

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo
echo "=== [6/7] Enable & Start Docker service ==="

sudo systemctl enable docker
sudo systemctl start docker

echo
echo "=== [7/7] Add current user to Docker group ==="

sudo usermod -aG docker "$USER"

echo
echo "====================================================="
echo " Docker Version"
echo "====================================================="

sudo docker --version

echo
echo "====================================================="
echo " Docker Compose Version"
echo "====================================================="

sudo docker compose version

echo
echo "====================================================="
echo " Docker Service Status"
echo "====================================================="

sudo systemctl --no-pager --full status docker | head -n 10

echo
echo "====================================================="
echo " Docker installation completed successfully!"
echo "====================================================="

echo
echo "User : $USER"
echo
echo "Docker:"
echo "  docker --version"
echo
echo "Docker Compose:"
echo "  docker compose version"
echo
echo "Test:"
echo "  docker run hello-world"
echo
echo "Apply docker group:"
echo "  newgrp docker"
echo
echo "Or logout/login again."
echo
echo "====================================================="