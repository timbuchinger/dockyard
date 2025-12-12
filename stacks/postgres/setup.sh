#!/usr/bin/env bash

sudo mkdir -p /var/lib/podman-volumes/postgres/data
sudo mkdir -p /var/lib/podman-volumes/postgres/pgadmin

sudo chown -R "999" /var/lib/podman-volumes/postgres/data
sudo chmod -R 700 /var/lib/podman-volumes/postgres/data

sudo chown -R "5050" /var/lib/podman-volumes/postgres/pgadmin
sudo chmod -R 700 /var/lib/podman-volumes/postgres/pgadmin

if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" != "Disabled" ]; then
  sudo chcon -Rt svirt_sandbox_file_t /var/lib/podman-volumes/postgres || true
fi

# Open firewall port for PostgreSQL on Rocky Linux (firewalld)
if command -v firewall-cmd >/dev/null 2>&1; then
	if sudo firewall-cmd --state >/dev/null 2>&1; then
		echo "Configuring firewall: opening 5432/tcp for postgres"
		sudo firewall-cmd --permanent --add-port=5432/tcp || true
		sudo firewall-cmd --reload || true
	else
		echo "firewalld is not running; skipping firewall changes for postgres. To enable: sudo systemctl enable --now firewalld"
	fi
else
	echo "firewall-cmd not found; skipping firewall changes for postgres"
fi
