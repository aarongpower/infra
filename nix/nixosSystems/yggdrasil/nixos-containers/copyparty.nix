# container for n8n
# also includes headless obsidian for inbox automation
{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  userName = "n8n";
  userHome = "/var/lib/n8n";
  userGroup = "n8n";
  userUid = 6973;
  userGid = 6973;
  vncPort = 5900;
  ipaddress = "192.168.3.36/24";
  defaultGateway = "192.168.3.1";
  nameservers = ["192.168.3.22"];
  unstable = true;
  nixpkgs =
    if unstable
    then inputs.nixpkgs-unstable
    else inputs.nixpkgs;
  pkgs = import nixpkgs {system = "x86_64-linux";};
in {
  services.cloudflared.tunnels."4dfe26fb-27ae-40c7-a941-11f50f3ed8c3".ingress = lib.mkAfter {
    "copyparty.rumahindo.net" = "http://192.168.3.36:3838";
  };

  # Before the service starts, make sure secrets are in a special folder
  # so we can bind-mount the contents into the container for access
  systemd.services.copyparty-secrets = {
    description = "Copy secrets for copyparty container";
    wantedBy = ["multi-user.target"];
    before = ["container@copyparty.service"];
    requiredBy = ["container@copyparty.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = [
        # Ensure directory exists before copying files
        "/run/current-system/sw/bin/mkdir -p /etc/container-copyparty-secrets"
      ];
      ExecStart = [
        # Fix storage permissions
        # "/run/current-system/sw/bin/chown -R ${toString userUid}:${toString userGid} /tank/obsidian"
        # "/run/current-system/sw/bin/chmod -R 0770 /tank/obsidian"
        # Copy secrets (instead of using systemd.tmpfiles C directive which creates symlinks)
        "/run/current-system/sw/bin/cp -f ${config.sops.secrets.container_copyparty_private_agekey.path} /etc/container-copyparty-secrets/agekey"
        "/run/current-system/sw/bin/cp -f ${globals.flakeRoot}/secrets/container-copyparty.yaml /etc/container-copyparty-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chown ${userName}:${userGroup} /etc/container-copyparty-secrets/agekey /etc/container-copyparty-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chmod 0400 /etc/container-copyparty-secrets/agekey /etc/container-copyparty-secrets/secrets.yaml"
      ];
    };
  };

  # Decrypt the age secret key for the container
  sops.secrets.container_copyparty_private_agekey = {};

  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
    uid = 6973; # or another free UID
    extraGroups = ["media"];
  };
  users.groups.copyparty = {
    gid = 6973; # or another free GID
  };

  containers.copyparty = {
    nixpkgs = nixpkgs;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipaddress;

    bindMounts = {
      "/media" = {
        hostPath = "/tank/media";
        isReadOnly = true;
      };
      "/run/container-secrets" = {
        hostPath = "/etc/container-copyparty-secrets";
        isReadOnly = true;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.copyparty.overlays.default
      ];
      environment.systemPackages = [pkgs.copyparty pkgs.ffmpeg pkgs.parallel];
      system.stateVersion = "25.05";

      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.copyparty.nixosModules.default
      ];

      users.users.copyparty = {
        isSystemUser = true;
        group = "copyparty";
        uid = 6973; # or another free UID
      };
      users.groups.copyparty = {
        gid = 6973; # or another free GID
      };
      users.groups.media = {
        members = ["copyparty"];
        gid = 1001;
      };

      sops = {
        defaultSopsFile = "/run/container-secrets/secrets.yaml";
        age.keyFile = "/run/container-secrets/agekey";
        # Disable validation since files only exist at runtime
        validateSopsFiles = false;
        secrets.aaronp_password = {
          owner = "copyparty";
          group = "copyparty";
        };
      };

      services.copyparty = {
        enable = true;

        settings = {
          # i = ipaddress;
          p = 3838;
          idp-hm-usr = "^Tailscale-User-Login^aarongpower@outlook.com^aaronp";
          xff-hdr = "192.168.3.20";
        };

        accounts = {
          aaronp.passwordFile = config.sops.secrets.aaronp_password.path;
        };

        volumes = {
          "/" = {
            path = "/media";
            access = {
              r = "*";
              rw = "aaronp";
            };
            flags = {
              scan = 60;
            };
          };
        };
      };

      systemd.services.copyparty = {
        serviceConfig = {
          DynamicUser = false;
          User = "copyparty";
          Group = lib.mkForce "media";
        };
      };

      networking.defaultGateway = defaultGateway;
      networking.nameservers = nameservers;
      networking.firewall = {
        enable = false;
        allowedTCPPorts = [3838];
      };
    };
  };
}
