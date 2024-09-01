{ pkgs, inputs, fenix, concierge, ... }:
with pkgs; [
  # Development Tools
  poetry
  inputs.compose2nix.packages.x86_64-linux.default
  # Fonts
  nerdfonts

  # Productivity
  obsidian
  vscode
  discord
  # Command-line Tools
  bat

  # zellij
  syncthing
  fzf-zsh

  # Customization
  starship

  alacritty
  # flatpak
  oh-my-zsh
  wget
  htop
  # ncdu
  nmap
  helix
  fenix.packages.${pkgs.system}.complete.toolchain
  # xsel
  # woeusb-ng
  eza
  tree
  ollama
  libgen-cli
  # magic-wormhole # using magic-wormhole-rs - this package fails build
  magic-wormhole-rs
  rage
  unrar
  drawio
  # blender - doesn't support aarch64-darwin yet, installed directly to nixos host only
  age-plugin-yubikey
  zip
  concierge.packages.${pkgs.system}.default
  # ansible
  ripgrep
  # rpi-imager
  # poppler_utils
  # darktable
  # zoxide
]
