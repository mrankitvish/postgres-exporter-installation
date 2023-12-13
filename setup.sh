#!/bin/bash

# Define variables
exporter_version="0.15.0"
exporter_download_url="https://github.com/prometheus-community/postgres_exporter/releases/download/v${exporter_version}/postgres_exporter-${exporter_version}.linux-amd64.tar.gz"
exporter_tar_file="postgres_exporter-${exporter_version}.linux-amd64.tar.gz"
exporter_binary="postgres_exporter"
exporter_user="postgres_exporter"
systemd_service_file="/etc/systemd/system/postgres-exporter.service"

# Step 1: Download and Extract the Exporter
wget $exporter_download_url
tar -xvf $exporter_tar_file
sudo mv ${exporter_binary}-${exporter_version}.linux-amd64/$exporter_binary /usr/local/bin/

# Step 2: Create a System User for the Exporter
sudo useradd --no-create-home --shell /bin/false $exporter_user
sudo chown $exporter_user:$exporter_user /usr/local/bin/$exporter_binary

# Step 3: Configure Systemd Service
echo "[Unit]
Description=Postgres Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${exporter_user}
Group=${exporter_user}
Type=simple
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/.postgres.env
ExecStart=/usr/local/bin/${exporter_binary}

[Install]
WantedBy=multi-user.target
" | sudo tee $systemd_service_file

# Step 4: Set Environment Variable for PostgreSQL Connection
read -p "Enter your PostgreSQL User: " user
read -p "Enter your PostgreSQL password: " postgres_password
read -p "Enter your PostgreSQL Host (eg. localhost): " host
read -p "Enter your PostgreSQL Database Name (eg. postgres): " db

# Step 5: Configuring
sudo mkdir /opt/postgres_exporter 
echo "DATA_SOURCE_NAME="postgresql://${user}:${postgres_password}@${host}:5432/${db}?sslmode=disable"" | sudo tee /opt/postgres_exporter/.postgres.env
sudo chown postgres_exporter:postgres_exporter /opt/postgres_exporter
sudo chown postgres_exporter:postgres_exporter /opt/postgres_exporter/.postgres.env

# Step 6: Enable and Start the Service
systemctl enable postgres-exporter.service
systemctl start postgres-exporter.service

# Cleanup
rm $exporter_tar_file
rm -r ${exporter_binary}-${exporter_version}.linux-amd64

echo "Prometheus PostgreSQL Exporter installation and configuration completed. curl http://localhost:9187/metrics"