#!/usr/bin/env bash

# ensure sbin is in path
PATH=/sbin:$PATH

if [[ "$(uname)" == "Darwin" ]]; then
  # install nix with determinate systems installer
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # resolve issue with missing cert
  sudo rm /etc/ssl/certs/ca-certificates.crt
  # sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt

  sudo rsync -ahi --delete --recursive --exclude ".stfolder" --exclude '*.lock' --exclude '.git' --exclude 'bootstrap.sh' --exclude '.gitignore' --exclude 'sync' --exclude 'dump.sh'  ~/.nixcfg/ ~/.config/nix

  # bootstrap nix-darwin installation
  nix run nix-darwin -- switch --flake ~/.config/nix
fi
