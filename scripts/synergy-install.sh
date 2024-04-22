#!/usr/bin/env bash

FLATPAK_ID="com.symless.synergy" # Replace with your actual Flatpak ID
FLATPAK_FILE="/etc/nixos/flatpak/synergy-linux_x64-libssl3-v3.0.78.1-rc3.flatpak" # Replace with the path to your .flatpak file

# Check if the Flatpak is already installed
if ! flatpak list | grep -q $FLATPAK_ID; then
    echo "Installing $FLATPAK_ID..."
    flatpak install -y $FLATPAK_FILE
fi
