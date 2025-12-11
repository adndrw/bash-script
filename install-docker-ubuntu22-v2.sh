#!/bin/bash
# =====================================================
# Script Install Docker & Docker Compose on Ubuntu 22.04
# Author : adndrw_
# Date   : 2025-10-15
# =====================================================

set -e

echo "=== [1/7] Update system packages ==="
sudo apt update -y 

echo "=== [2/7] Install required dependencies ==="
sudo apt install ca-certificates curl gnupg lsb-release -y

echo "=== [3/7] Add Docker’s official GPG key ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "=== [4/7] Add Docker repository ==="
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== [5/7] Install Docker Engine, CLI, and plugins ==="
sudo apt update -y
sudo apt install docker-ce docker-compose-plugin -y

echo "=== [6/7] Enable & Start Docker service ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== [7/7] Add current user to Docker group ==="
sudo usermod -aG docker $USER

echo "=== [Optional] Installing Docker Compose v2 (classic CLI) ==="
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo
echo "====================================================="
echo "✅ Docker installation completed successfully!"
echo "🚀 Please run 'newgrp docker' or re-login to apply group changes."
echo "🔍 Test with: docker run hello-world"
echo "====================================================="
