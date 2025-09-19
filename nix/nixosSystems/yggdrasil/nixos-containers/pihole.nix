{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  ipaddress = "192.168.3.37";
  subnetbits = 24;
  ipcidr = "${ipaddress}/${toString subnetbits}";
  hostname = "pihole.sol.rumahindo.net";
  defaultGateway = "192.168.3.1";
  nameservers = ["1.1.1.1 9.9.9.9"]; # upstream for the container itself during boot
  allowUnfree = true;
  system = "x86_64-linux";

  # If you like to pick nixpkgs per-container (as in your example):
  nixpkgsSrc = inputs.nixpkgs-unstable;
  pkgs = import nixpkgsSrc {system = system;};

  # Where to keep Pi-hole volumes (inside the container FS)
  volPath = "/etc/pihole"; # pihole flake seems to put it here, we'll align to pull it through to the host system
in {
  containers.pihole = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipaddress;

    # Persist Pi-hole across container rebuilds by bind-mounting the volumes path
    bindMounts = {
      "${volPath}" = {
        hostPath = "/tank/containers/pihole"; # adjust to taste
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
        podman
      ];

      virtualisation.podman.enable = true;

      # Give the container its own LAN presence
      networking.defaultGateway = defaultGateway;
      networking.nameservers = nameservers;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [53 80];
        allowedUDPPorts = [53];
      };

      # Let rootless Podman bind to 53/80 *inside this netns only*
      boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;
      # required for stable restarts of the Pi-hole container
      boot.tmp.cleanOnBoot = true;

      imports = [
        inputs.linger.nixosModules.${system}.default
        inputs.pihole.nixosModules.${system}.default
      ];

      users.users.pihole = {
        isNormalUser = true;
        description = "Pi-hole rootless user";
        createHome = true;
        home = "/home/pihole";
        # Required for rootless Podman
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };

      # Tell the Pi-hole module where to put its volumes
      services.pihole = {
        enable = true;
        hostConfig = {
          # define the service user for running the rootless Pi-hole container
          user = "pihole";
          enableLingeringForUser = true;

          # we want to persist change to the Pi-hole configuration & logs across service restarts
          # check the option descriptions for more information
          persistVolumes = true;

          # expose DNS & the web interface on unpriviledged ports on all IP addresses of the host
          # check the option descriptions for more information
          dnsPort = 53;
          webPort = 80;
        };
        piholeConfig = {
          tz = globals.timezone;
          ftl = {
            # assuming that the host has this (fixed) IP and should resolve "pi.hole" to this address
            # check the option description & the FTLDNS documentation for more information
            LOCAL_IPV4 = ipaddress;
          };
          web = {
            virtualHost = "pi.hole";
            password = "password";
          };
        };
      };

      # Force the unit to run as root (rootful podman)
      systemd.services.pihole-rootless-container.serviceConfig.User = lib.mkForce "root";

      # Podman (root) wants a signature policy; give a sane default
      environment.etc."containers/policy.json".text = lib.mkDefault ''
        {
          "default": [ { "type": "insecureAcceptAnything" } ],
          "transports": {
            "docker-daemon": { "": [ { "type": "insecureAcceptAnything" } ] }
          }
        }
      '';

      # Optional: send container logs to journald by default (nice with systemd)
      # environment.etc."containers/containers.conf".text = ''
      #   [engine]
      #   log_driver="journald"
      # '';

      # Free up privileged ports so Pi-hole can bind :53/:80 cleanly
      # services.resolved.enable = lib.mkDefault true;
      # services.resolved.dnsStubListener = lib.mkDefault false;

      system.stateVersion = "24.11";
    };
  };
}
