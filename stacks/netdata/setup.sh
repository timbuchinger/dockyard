#!/usr/bin/env bash

# Netdata host setup script
# Ensures host volume directories exist and are writable by the Netdata container user

set -u

DATA_DIR="/var/lib/podman-volumes/netdata/lib"
CACHE_DIR="/var/lib/podman-volumes/netdata/cache"
REGISTRY_DIR="$DATA_DIR/registry"
CLOUD_DIR="$DATA_DIR/cloud.d"

# Netdata image uses UID:GID 201:201 (container user 'netdata')
NETDATA_UID=201
NETDATA_GID=201

echo "Creating netdata host directories under $DATA_DIR and $CACHE_DIR"
sudo mkdir -p "$REGISTRY_DIR" "$CLOUD_DIR" "$DATA_DIR" "$CACHE_DIR"

echo "Setting ownership to ${NETDATA_UID}:${NETDATA_GID} and permissions to 0755"
sudo chown -R ${NETDATA_UID}:${NETDATA_GID} "$DATA_DIR" "$CACHE_DIR" || true
sudo chmod -R 0755 "$DATA_DIR" "$CACHE_DIR" || true

# If SELinux is enabled, relabel the directories for container access
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce 2>/dev/null)" = "Enforcing" ]; then
  if command -v chcon >/dev/null 2>&1; then
	echo "SELinux is enforcing — applying container_file_t label to netdata data dirs"
	sudo chcon -R -t container_file_t "$DATA_DIR" "$CACHE_DIR" || true
  else
	echo "SELinux appears enabled but 'chcon' not found. If needed, relabel $DATA_DIR and $CACHE_DIR with container_file_t"
  fi
fi

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

echo "Netdata host setup complete."
