#!/usr/bin/env bash

set -euo pipefail

DATA_DIR=/var/lib/podman-volumes/portainer/data

sudo mkdir -p "$DATA_DIR"
# Ensure Portainer can write into the data directory. Use recursive chown/chmod to avoid permission denied errors.
sudo chown -R 1000:1000 "$DATA_DIR"
sudo chmod -R 775 "$DATA_DIR"

# If SELinux is enabled (common on RHEL/Rocky/CentOS), adjust the label so Podman/container can access the bind mount.
if command -v getenforce >/dev/null 2>&1; then
	if [ "$(getenforce)" != "Disabled" ]; then
		echo "SELinux is enabled; applying container-friendly label to $DATA_DIR"
		sudo chcon -Rt svirt_sandbox_file_t "$DATA_DIR" || true
	fi
fi

# Open firewall ports for Portainer on Rocky Linux (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
	if sudo firewall-cmd --state >/dev/null 2>&1; then
		echo "Configuring firewall: opening 9000/tcp, 9443/tcp, 8000/tcp for portainer"
		sudo firewall-cmd --permanent --add-port=9000/tcp || true
		sudo firewall-cmd --permanent --add-port=9443/tcp || true
		sudo firewall-cmd --permanent --add-port=8000/tcp || true
		sudo firewall-cmd --reload || true
	else
		echo "firewalld is not running; skipping firewall changes for portainer. To enable: sudo systemctl enable --now firewalld"
	fi
else
	echo "firewall-cmd not found; skipping firewall changes for portainer"
fi
