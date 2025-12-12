#!/usr/bin/env bash

sudo mkdir -p /var/lib/podman-volumes/portainer/data
sudo chown 1000:1000 /var/lib/podman-volumes/portainer/data

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
