# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, flakeRoot, ... }:

let
  importWithExtras = filePath: import filePath { inherit config pkgs lib flakeRoot; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./user.nix
    # ./docker/overseer/docker-compose.nix
    # ./docker/whisparr/docker-compose.nix
    # ./docker/odoo/odoo.nix
     ./services.nix
    # ./programs.nix
    (importWithExtras ./age.nix)
    ./environment.nix
    ./networking.nix
    ./security.nix
    # ../home/nixos.nix
  ];
  
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  nix = {
    extraOptions = ''
      auto-optimise-store = true
    '';

    settings = {
      experimental-features = [ "nix-command" "flakes" ]; # enable flakes
      substituters = [
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # };

  nixpkgs = {
    config.allowUnfree = true; # Allow unfree packages
    config.permittedInsecurePackages = [
      # "electron-25.9.0" # TODO: Remove this in the future, required so I can install Obsidian
      # "electron-19.1.9" # TODO: Remove this in the future, required so I can install Etcher
      # "python3.11-apache-airflow-2.7.3"
    ];
  };
 
  # Enable virtualisation
  virtualisation.libvirtd.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
 
  # configure tailscale as an exit node
  #boot.kernel.sysctl = {
  #  "net.ipv4.ip_forward" = 1;
  #  "net.ipv6.conf.all.forwarding" = 1;
  #};
}
