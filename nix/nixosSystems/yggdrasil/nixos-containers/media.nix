{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  ipaddress = "192.168.3.27/24";
  defaultGateway = "192.168.3.1";
  nameservers = ["192.168.3.22"];
  unstable = true;
  allowUnfree = true;

  nixpkgs =
    if unstable
    then inputs.nixpkgs-unstable
    else inputs.nixpkgs;
  pkgs = import nixpkgs {
    system = "x86_64-linux";
  };
in {
  containers.media = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipaddress;
    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "/tank/containers/media/jellyfin";
        isReadOnly = false;
      };
      "/var/lib/plex" = {
        hostPath = "/tank/containers/media/plex";
        isReadOnly = false;
      };
      "/var/lib/radarr" = {
        hostPath = "/tank/containers/media/radarr";
        isReadOnly = false;
      };
      "/var/lib/sonarr" = {
        hostPath = "/tank/containers/media/sonarr";
        isReadOnly = false;
      };
      "/var/lib/sabnzbd" = {
        hostPath = "/tank/containers/media/sabnzbd";
        isReadOnly = false;
      };
      "/var/lib/private/prowlarr" = {
        hostPath = "/tank/containers/media/prowlarr";
        isReadOnly = false;
      };
      "/var/lib/bazarr" = {
        hostPath = "/tank/containers/media/bazarr";
        isReadOnly = false;
      };
      "/media" = {
        hostPath = "/tank/media";
        isReadOnly = false;
      };
      "/downloads" = {
        hostPath = "/tank/downloads";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      nixpkgs.config.allowUnfree = allowUnfree;

      environment.systemPackages = with pkgs; [
        jq
      ];

      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };
      services.plex = {
        enable = true;
        openFirewall = true;
        user = "root";
        group = "root";
      };
      services.radarr = {
        enable = true;
        openFirewall = true;
        user = "root";
        group = "root";
      };
      services.sonarr = {
        enable = true;
        openFirewall = true;
        user = "root";
        group = "root";
      };
      services.sabnzbd = {
        enable = true;
        openFirewall = true;
        user = "root";
        group = "root";
      };
      services.prowlarr = {
        enable = true;
        openFirewall = true;
      };
      services.bazarr = {
        enable = true;
        openFirewall = true;
        user = "root";
        group = "root";
      };
      networking.firewall = {
        enable = true;
      };
      networking.defaultGateway = defaultGateway;
      networking.nameservers = nameservers;
      system.stateVersion = "24.11";
    };
  };
}
