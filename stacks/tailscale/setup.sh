#!/usr/bin/env bash

sudo mkdir -p /var/lib/podman-volumes/tailscale/lib
sudo mkdir -p /var/lib/podman-volumes/tailscale/run

# Ensure /dev/net/tun exists (required for Tailscale)
if [ ! -c /dev/net/tun ]; then
  if command -v modprobe >/dev/null 2>&1; then
    sudo modprobe tun || true
  fi
  if [ ! -c /dev/net/tun ]; then
    sudo mkdir -p /dev/net
    sudo mknod -m 600 /dev/net/tun c 10 200 || true
  fi
fi

# Open firewall port for Tailscale UDP (DERP/peer-to-peer traffic)
if command -v firewall-cmd >/dev/null 2>&1; then
  if sudo firewall-cmd --state >/dev/null 2>&1; then
    echo "Configuring firewall: opening 41641/udp for tailscale"
    sudo firewall-cmd --permanent --add-port=41641/udp || true
    sudo firewall-cmd --reload || true
  else
    echo "firewalld is not running; skipping firewall changes for tailscale. To enable: sudo systemctl enable --now firewalld"
  fi
else
  echo "firewall-cmd not found; skipping firewall changes for tailscale"
fi

echo "Created podman volume directories in /var/lib/podman-volumes/tailscale"
