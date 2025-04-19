{
  pkgs,
  inputs,
  fenix,
  unstablePkgs,
  ...
}:
with pkgs; [
  # from inputs
  inputs.alejandra.packages.${pkgs.system}.default
  inputs.compose2nix.packages.${pkgs.system}.default
  inputs.concierge.packages.${pkgs.system}.default
  inputs.fenix.packages.${pkgs.system}.complete.toolchain

  # from pkgs
  _1password-cli
  age-plugin-yubikey
  ansible
  bat
  chatgpt-cli
  unstablePkgs.codex
  dig
  fzf-zsh
  eza
  helix
  htop
  kompose
  libgen-cli
  # magic-wormhole # using magic-wormhole-rs - this package fails build
  magic-wormhole-rs
  ncdu
  neofetch
  nil
  nmap
  ollama
  poetry
  rage
  ripgrep
  sops
  starship
  syncthing
  terraform
  tree
  unrar
  wget
  zellij
  zip
]
