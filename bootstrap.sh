#!/usr/bin/env bash

set -e

# Function to list available disks
list_disks() {
  echo "=== Available Disks ==="
  lsblk -d -e 7,11 -o NAME,SIZE,MODEL,SERIAL
  echo ""
  echo "Disk IDs in /dev/disk/by-id/:"
  ls -l /dev/disk/by-id/ | grep -E "ata|nvme|scsi|sd"
  echo ""
}

# Prompt for the hostname
read -p "Enter the hostname for this system: " HOSTNAME

# List the disks
list_disks

echo "Please note the disk IDs (e.g., /dev/disk/by-id/ata-...) for your ZFS configuration."

echo ""
echo "=== ACTION REQUIRED ==="
echo "Update your flake configuration with the appropriate ZFS disk IDs."
echo "Ensure the configuration for hostname '${HOSTNAME}' includes the correct disk IDs."
echo "Once you've updated your flake, push the changes to GitHub."
echo ""
read -p "Have you updated your flake configuration and pushed it to GitHub? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Please update your flake configuration and push it to GitHub before proceeding."
  exit 1
fi

# Enable Nix flakes
echo "=== Enabling Nix Flakes ==="
mkdir -p /etc/nix
if ! grep -q "experimental-features = nix-command flakes" /etc/nix/nix.conf; then
  echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
fi

# Install Git and 'concierge'
echo "=== Installing Git and 'concierge' ==="
nix profile install nixpkgs#git
nix profile install "github:aarongpower/nix-concierge"

# Clone your configuration
echo "=== Cloning Configuration ==="
if [ ! -d "/root/.config/nix" ]; then
  mkdir -p /root/.config
  git clone https://github.com/yourusername/your-flake-repo.git /root/.config/nix
else
  echo "Configuration already cloned."
fi

# Verify that the flake contains the hostname configuration
echo "=== Verifying Flake Configuration ==="
if ! grep -q "${HOSTNAME}" /root/.config/nix/flake.nix; then
  echo "Error: Hostname '${HOSTNAME}' not found in flake configuration."
  echo "Please ensure you've added the configuration for '${HOSTNAME}' and try again."
  exit 1
fi

# Run 'concierge' to deploy the configuration
echo "=== Deploying Configuration Using 'concierge' ==="
cd /root/.config/nix
concierge deploy

echo "=== Bootstrap Complete ==="
echo "Please reboot the system."

