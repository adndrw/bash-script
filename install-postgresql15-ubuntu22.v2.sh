#!/bin/bash
set -e

echo "==== Update system package ===="
sudo apt update -y

echo "==== Install dependencies ===="
sudo apt install -y wget gnupg lsb-release

echo "==== Add PostgreSQL APT repository ===="
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/postgresql.gpg >/dev/null
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

echo "==== Update repo ===="
sudo apt update -y

echo "==== Install PostgreSQL 15 ===="
sudo apt install -y postgresql-15 postgresql-client-15

echo "==== Enable & start PostgreSQL ===="
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "==== Set password for postgres user ===="
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres123';"

echo "==== Update listen_addresses to allow remote connection (optional) ===="
PG_CONF="/etc/postgresql/15/main/postgresql.conf"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $PG_CONF

echo "==== Update pg_hba.conf to allow remote access (optional) ===="
HBA_CONF="/etc/postgresql/15/main/pg_hba.conf"
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a $HBA_CONF >/dev/null
echo "host    all             all             ::/0                    md5" | sudo tee -a $HBA_CONF >/dev/null

echo "==== Restart PostgreSQL ===="
sudo systemctl restart postgresql

echo "==== Installation Completed Successfully ===="
echo "PostgreSQL 15 installed!"
echo "postgres user password: postgres123"
echo "You may change it using: sudo -u postgres psql"
