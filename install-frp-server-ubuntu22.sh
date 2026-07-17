#!/bin/bash

set -e

FRP_VERSION="0.65.0"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/frp"

echo "Installing FRP Server v${FRP_VERSION}"

cd /tmp

wget -q https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz

tar -xzf frp_${FRP_VERSION}_linux_amd64.tar.gz

cd frp_${FRP_VERSION}_linux_amd64

cp frps ${INSTALL_DIR}/
chmod +x ${INSTALL_DIR}/frps

mkdir -p ${CONFIG_DIR}

cat > ${CONFIG_DIR}/frps.toml <<EOF
bindPort = 7000

auth.method = "token"
auth.token = "CHANGE_ME_TOKEN"

webServer.addr = "127.0.0.1"
webServer.port = 7500

webServer.user = "admin"
webServer.password = "CHANGE_ME_PASSWORD"

transport.tls.force = true
EOF

cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=FRP Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.toml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frps
systemctl restart frps

echo ""
echo "FRPS Installed"
echo ""
echo "Config : /etc/frp/frps.toml"
echo "Service: systemctl status frps"