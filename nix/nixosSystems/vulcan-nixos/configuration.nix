{
  config,
  pkgs,
  lib,
  globals,
  ...
}: let
  importWithExtras = filePath: import filePath {inherit config pkgs lib globals;};
in {
  imports = [
    (importWithExtras ./age.nix)
    ./environment.nix
    ./networking.nix
    ./programs.nix
    ./security.nix
    ./user.nix
    ./services.nix
    "${globals.flakeRoot}/ssh/knownHosts.nix"
  ];

  # nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  wsl.enable = true;
  wsl.defaultUser = "aaronp";
  wsl.wslConf.network.generateResolvConf = false;

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    git
    curl
    helix
    direnv
    poetry
    zellij
    wormhole-rs
  ];

  # Weekly garbage collection
  # Delete generations older than 30 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # optimise the store periodically
  nix.optimise.automatic = true;
}
