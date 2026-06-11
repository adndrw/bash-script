#!/bin/bash

set -e

FRP_VERSION="0.65.0"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/frp"

echo "Installing FRP Client v${FRP_VERSION}"

cd /tmp

wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz

tar -xzf frp_${FRP_VERSION}_linux_amd64.tar.gz

cd frp_${FRP_VERSION}_linux_amd64

cp frpc ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frpc

mkdir -p ${CONFIG_DIR}

cat > ${CONFIG_DIR}/frpc.toml <<EOF
serverAddr = "VPS_PUBLIC_IP"
serverPort = 7000

auth.method = "token"
auth.token = "CHANGE_ME_TOKEN"

transport.tls.enable = true

[[proxies]]
name = "CHANGE_ME_NAME"
type = "tcp"

localIP = "127.0.0.1"
localPort = 22

remotePort = 6000
EOF

cat > /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=FRP Client
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frpc
systemctl restart frpc

echo ""
echo "FRPC Installed"
echo ""
echo "Config : /etc/frp/frpc.toml"
echo "Service: systemctl status frpc"