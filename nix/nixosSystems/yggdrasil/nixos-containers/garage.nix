{
  config,
  pkgs,
  inputs,
  lib,
  globals,
  ...
}: {
  systemd.tmpfiles.rules = [
    # Storage directories
    "d /tank/garage 0770 6971 6971 -"
    "d /tank/garage/meta 0770 6971 6971 -"
    "d /tank/garage/data 0770 6971 6971 -"
    "d /tank/garage/snapshots 0770 6971 6971 -"
  ];
  systemd.services.fix-garage-perms = {
    description = "Fix permissions and copy secrets for Garage container";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = [
        # Ensure directory exists before copying files
        "/run/current-system/sw/bin/mkdir -p /etc/container-garage-secrets"
      ];
      ExecStart = [
        # Fix storage permissions
        "/run/current-system/sw/bin/chown -R 6971:6971 /tank/garage"
        "/run/current-system/sw/bin/chmod -R 0770 /tank/garage"
        # Copy secrets (instead of using systemd.tmpfiles C directive which creates symlinks)
        "/run/current-system/sw/bin/cp -f ${config.sops.secrets.container_garage_sops_private_agekey.path} /etc/container-garage-secrets/agekey"
        "/run/current-system/sw/bin/cp -f ${globals.flakeRoot}/secrets/container-garage.yaml /etc/container-garage-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chown garage:garage /etc/container-garage-secrets/agekey /etc/container-garage-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chmod 0400 /etc/container-garage-secrets/agekey /etc/container-garage-secrets/secrets.yaml"
      ];
    };
  };
  users.users.garage = {
    isSystemUser = true;
    group = "garage";
    uid = 6971; # or another free UID
  };
  users.groups.garage = {
    gid = 6971; # or another free GID
  };
  sops.secrets.container_garage_sops_private_agekey = {};
  containers.garage = let
    ipaddress = "192.168.3.34/24";
    defaultGateway = "192.168.3.1";
    nameservers = ["192.168.3.22"];
    unstable = true;
    nixpkgs =
      if unstable
      then inputs.nixpkgs-unstable
      else inputs.nixpkgs;
    pkgs = import nixpkgs {system = config.nixpkgs.system;}; # or use `config.nixpkgs.system`
  in {
    nixpkgs = nixpkgs;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipaddress;
    bindMounts = {
      "/garage" = {
        hostPath = "/tank/garage";
        isReadOnly = false;
      };
      "/run/container-secrets" = {
        hostPath = "/etc/container-garage-secrets";
        isReadOnly = true;
      };
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      systemd.services.garage = {
        serviceConfig = {
          DynamicUser = false;
          User = "garage";
        };
        # Add pre-start script to verify files exist
        preStart = ''
          echo "Checking if secret paths exist:"
          echo "RPC secret file: ${config.sops.secrets.rpc_secret.path}"
          test -f ${config.sops.secrets.rpc_secret.path} && echo "RPC secret exists" || echo "RPC secret MISSING"

          echo "Checking service directories:"
          ls -la /garage
          echo "Checking garage secrets dir:"
          ls -la /run/container-secrets || echo "Secrets directory MISSING"

          # Check if sops secrets are properly decrypted
          cat ${config.sops.secrets.rpc_secret.path} | wc -c

          # Check which SOPS secrets are available
          ls -la /run/secrets/ || echo "Run secrets directory MISSING"

          # Show where Garage is looking for files
          echo "Garage will look for: ${config.services.garage.settings.rpc_secret_file}"
        '';
      };
      users.users.garage = {
        isSystemUser = true;
        group = "garage";
        uid = 6971; # or another free UID
      };
      users.groups.garage = {
        gid = 6971; # or another free GID
      };
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      sops = {
        defaultSopsFile = "/run/container-secrets/secrets.yaml";
        age.keyFile = "/run/container-secrets/agekey";
        # Disable validation since files only exist at runtime
        validateSopsFiles = false;
        secrets.rpc_secret = {
          owner = "garage";
          group = "garage";
        };
        secrets.admin_token = {
          owner = "garage";
          group = "garage";
        };
        secrets.metrics_token = {
          owner = "garage";
          group = "garage";
        };
      };
      environment.systemPackages = with pkgs; [];
      services.garage = {
        enable = true;
        package = pkgs.garage;
        settings = {
          metadata_dir = "/garage/meta";
          data_dir = "/garage/data";
          metadata_snapshots_dir = "/garage/snapshots";
          db_engine = "sqlite";

          replication_factor = 1;

          rpc_bind_addr = "0.0.0.0:3901";
          rpc_public_addr = "192.168.3.34:3901";
          rpc_secret_file = config.sops.secrets.rpc_secret.path;

          metadata_fsync = true;
          data_fsync = true;
          use_local_tz = false;

          s3_api = {
            api_bind_addr = "192.168.3.34:3900";
            s3_region = "gamping";
            root_domain = ".s3.rumahindo.net";
          };

          s3_web = {
            bind_addr = "0.0.0.0:3902";
            root_domain = "web.s3.rumahindo.net";
            index = "index.html";
          };

          k2v_api = {
            api_bind_addr = "0.0.0.0:3904";
          };

          admin = {
            api_bind_addr = "0.0.0.0:3903";
            admin_token_file = config.sops.secrets.admin_token.path;
            metrics_token_file = config.sops.secrets.metrics_token.path;
          };
        };
      };
      networking.firewall = {
        enable = false;
      };
      networking.defaultGateway = defaultGateway;
      networking.nameservers = nameservers;
      system.stateVersion = "24.11";
    };
  };
}
