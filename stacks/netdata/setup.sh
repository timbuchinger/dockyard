#!/usr/bin/env bash

sudo mkdir -p /var/lib/podman-volumes/netdata/lib
sudo mkdir -p /var/lib/podman-volumes/netdata/cache

# Open firewall port for Netdata on Rocky Linux (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
	if sudo firewall-cmd --state >/dev/null 2>&1; then
		echo "Configuring firewall: opening 19999/tcp for netdata"
		sudo firewall-cmd --permanent --add-port=19999/tcp || true
		sudo firewall-cmd --reload || true
	else
		echo "firewalld is not running; skipping firewall changes for netdata. To enable: sudo systemctl enable --now firewalld"
	fi
else
	echo "firewall-cmd not found; skipping firewall changes for netdata"
fi
