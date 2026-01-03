#!/bin/bash
# Ubuntu 24.04 Base Template Setup
# Installs qemu-guest-agent and basic utilities

set -e

echo "==> Setting up ubuntu-2404-base template..."

export DEBIAN_FRONTEND=noninteractive

# Wait for apt locks
wait_for_apt() {
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for apt lock..."
        sleep 5
    done
}

# Update system
echo "==> Updating system packages..."
wait_for_apt
apt-get update
apt-get -y upgrade

# Install qemu-guest-agent (critical for Packer/Proxmox integration)
echo "==> Installing qemu-guest-agent..."
wait_for_apt
apt-get -y install qemu-guest-agent

# Enable and start qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

# Install basic utilities
echo "==> Installing basic utilities..."
wait_for_apt
apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    wget \
    vim \
    htop \
    net-tools \
    dnsutils \
    jq

echo "==> Base template setup complete!"
