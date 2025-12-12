#!/usr/bin/env bash

sudo mkdir -p /var/lib/podman-volumes/redis/data

# Open firewall port for Redis on Rocky Linux (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
	if sudo firewall-cmd --state >/dev/null 2>&1; then
		echo "Configuring firewall: opening 6379/tcp for redis"
		sudo firewall-cmd --permanent --add-port=6379/tcp || true
		sudo firewall-cmd --reload || true
	else
		echo "firewalld is not running; skipping firewall changes for redis. To enable: sudo systemctl enable --now firewalld"
	fi
else
	echo "firewall-cmd not found; skipping firewall changes for redis"
fi
