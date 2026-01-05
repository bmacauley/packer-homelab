#!/bin/bash
# Ubuntu 24.04 Homelab Template Setup
# Installs tailscale, avahi, and homelab utilities

set -e

echo "==> Setting up ubuntu-2404-homelab template..."

export DEBIAN_FRONTEND=noninteractive

# Wait for apt locks
wait_for_apt() {
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for apt lock..."
        sleep 5
    done
}

# Update package list
echo "==> Updating package list..."
wait_for_apt
apt-get update

# Install avahi for mDNS/Bonjour
echo "==> Installing avahi..."
wait_for_apt
apt-get -y install avahi-daemon avahi-utils
systemctl enable avahi-daemon

# Install tailscale
echo "==> Installing tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
systemctl enable tailscaled

# Install additional homelab utilities
echo "==> Installing homelab utilities..."
wait_for_apt
apt-get -y install \
    git \
    unzip \
    rsync \
    tmux \
    tree \
    ncdu \
    iotop \
    sysstat

# Install Ansible
echo "==> Installing Ansible..."
wait_for_apt
apt-get -y install pipx
pipx ensurepath
pipx install --include-deps ansible

# Configure timezone
echo "==> Setting timezone to UTC..."
timedatectl set-timezone UTC

# Enable NTP
systemctl enable systemd-timesyncd
systemctl start systemd-timesyncd

echo "==> Homelab template setup complete!"
