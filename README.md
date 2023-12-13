# Prometheus PostgreSQL Exporter Installation

This repository provides a step-by-step guide and scripts for installing and configuring Prometheus PostgreSQL Exporter on a Linux system. 
`Tested on Ubuntu 22.04 LTS.`

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- A PostgreSQL database instance
- Access to the Linux system where you want to install the exporter
- sudo privileges on the Linux system


## Installation Steps

### 1. Download and Extract the Exporter

Download the PostgreSQL Exporter version 0.15.0 for Linux AMD64 and extract the contents:

```bash
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar -xvf postgres_exporter-0.15.0.linux-amd64.tar.gz
sudo mv postgres_exporter-0.15.0.linux-amd64/postgres_exporter /usr/local/bin/
```

### 2. Create a System User for the Exporter
Create a dedicated system user for running the PostgreSQL Exporter:

```bash
sudo useradd --no-create-home --shell /bin/false postgres_exporter
sudo chown postgres_exporter:postgres_exporter /usr/local/bin/postgres_exporter
```

### 3. Configure Systemd Service
Create a systemd service file for the PostgreSQL Exporter:
```bash
echo "[Unit]
Description=Postgres Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=postgres_exporter
Group=postgres_exporter
Type=simple
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/.postgres.env
ExecStart=/usr/local/bin/postgres_exporter

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/postgres-exporter.service
```

### 4. Set Environment Variable for PostgreSQL Connection
Set the DATA_SOURCE_NAME environment variable with the connection details to your PostgreSQL database:

```bash
sudo mkdir /opt/postgres_exporter 
echo "DATA_SOURCE_NAME="postgresql://<username>:<password>@<host>:5432/postgres?sslmode=disable"" | sudo tee /opt/postgres_exporter/.postgres.env
sudo chown postgres_exporter:postgres_exporter /opt/postgres_exporter
sudo chown postgres_exporter:postgres_exporter /opt/postgres_exporter/.postgres.env

```
Replace <user>, <password> and <host> with your actual PostgreSQL credentials.

### 5. Enable and Start the Service
Enable the PostgreSQL Exporter service to start on boot and start the service:

```bash
systemctl enable postgres-exporter.service
systemctl start postgres-exporter.service
```
### Monitoring
Once the exporter is running, you can access metrics at http://localhost:9187/metrics. Configure your Prometheus server to scrape these metrics for monitoring your PostgreSQL instance.

