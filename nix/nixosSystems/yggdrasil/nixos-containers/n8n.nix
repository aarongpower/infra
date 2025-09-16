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
  userUid = 6972;
  userGid = 6972;
  vncPort = 5900;
  ipaddress = "192.168.3.35/24";
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
    "n8n.rumahindo.net" = "http://192.168.3.35:3000";
  };
  # Before the service starts, make sure secrets are in a special folder
  # so we can bind-mount the contents into the container for access
  systemd.services.n8n-perms-secrets = {
    description = "Fix permissions and copy secrets for n8n container";
    wantedBy = ["multi-user.target"];
    before = ["container@n8n.service"];
    requiredBy = ["container@n8n.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = [
        # Ensure directory exists before copying files
        "/run/current-system/sw/bin/mkdir -p /etc/container-n8n-secrets"
      ];
      ExecStart = [
        # Fix storage permissions
        "/run/current-system/sw/bin/chown -R ${toString userUid}:${toString userGid} /tank/obsidian"
        "/run/current-system/sw/bin/chmod -R 0770 /tank/obsidian"
        # Copy secrets (instead of using systemd.tmpfiles C directive which creates symlinks)
        "/run/current-system/sw/bin/cp -f ${config.sops.secrets.container_n8n_private_agekey.path} /etc/container-n8n-secrets/agekey"
        "/run/current-system/sw/bin/cp -f ${globals.flakeRoot}/secrets/container-n8n.yaml /etc/container-n8n-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chown ${userName}:${userGroup} /etc/container-n8n-secrets/agekey /etc/container-n8n-secrets/secrets.yaml"
        "/run/current-system/sw/bin/chmod 0400 /etc/container-n8n-secrets/agekey /etc/container-n8n-secrets/secrets.yaml"
      ];
    };
  };

  # On the host we create a user and group for the container
  users.users.${userName} = {
    isSystemUser = true;
    group = "${userGroup}";
    uid = userUid;
  };
  users.groups.${userGroup} = {
    gid = userGid;
  };

  # Decrypt the age secret key for the container
  sops.secrets.container_n8n_private_agekey = {};
  containers.n8n = {
    nixpkgs = nixpkgs;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipaddress;

    bindMounts = {
      "/obsidian" = {
        hostPath = "/tank/obsidian";
        isReadOnly = false;
      };
      "/run/container-secrets" = {
        hostPath = "/etc/container-n8n-secrets";
        isReadOnly = true;
      };
      "/n8n" = {
        hostPath = "/tank/containers/n8n";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "25.05";

      # setting some n8n config here
      # figuring out how to set these in services.n8n.settings is not working
      environment.variables = {
        N8N_HOST = "n8n.rumahindo.net";
        N8N_PORT = "3000";
        N8N_LISTEN_ADDRESS = ipaddress;
      };
      services.n8n = {
        enable = true;
        webhookUrl = "https://n8n.rumahindo.net/";
        settings = {
          # settings are not well behaved
          # so we set them in environment.variables instead
          # schema for settings json is limited, so best to just use env vars
        };
      };

      systemd.services.n8n = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = userName;
          ReadWritePaths = [
            "/obsidian"
            "/n8n"
          ];
        };
        environment = {
          N8N_LISTEN_ADDRESS = "0.0.0.0"; # bind to all interfaces
          N8N_PORT = "3000";
          N8N_HOST = "n8n.rumahindo.net";
        };
      };

      users.users.${userName} = {
        isNormalUser = true;
        home = "/var/lib/${userName}";
        group = "${userGroup}";
        uid = userUid;
      };
      users.groups.${userGroup} = {
        gid = userGid;
      };

      environment.systemPackages = with pkgs; [
        obsidian
        xorg.xvfb
        x11vnc
        openbox
        inotify-tools
        xdg-utils
        desktop-file-utils
        difftastic
      ];

      programs.git = {
        enable = true;
        package = pkgs.git;
        config = {
          safe.directory = ["/obsidian"];
          user = {
            email = "aarongpower@gmail.com";
            name = "Aaron Power";
          };
        };
      };

      # Create obsidian directory
      systemd.tmpfiles.rules = [
        "d /obsidian/.obsidian 0755 ${userName} ${userGroup} -"
        "d /obsidian/.obsidian/plugins 0755 ${userName} ${userGroup} -"
        # "C /obsidian/.obsidian/plugins/obsidian-advanced-uri 0755 ${userName} ${userGroup} - ${advancedUriPlugin}"
      ];

      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      sops = {
        defaultSopsFile = "/run/container-secrets/secrets.yaml";
        age.keyFile = "/run/container-secrets/agekey";
        validateSopsFiles = false;
      };

      # Place .desktop file in a visible system directory
      # used so that xdg-open can find it and call Obsidian Advanced URI Plugin
      # Place obsidian.desktop in a standard system location
      environment.etc."xdg/applications/obsidian.desktop".source = "${pkgs.obsidian}/share/applications/obsidian.desktop";

      systemd.services.update-mime-database = {
        description = "Update MIME database for obsidian desktop file";
        wantedBy = ["multi-user.target"];
        before = ["obsidian.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.desktop-file-utils}/bin/update-desktop-database /etc/xdg/applications";
        };
      };

      # Register Obsidian as handler for obsidian:// (run as user, ideally at session start)
      # If you have a user session, use a user service:
      systemd.services.register-obsidian-handler = {
        description = "Register obsidian:// handler for n8n";
        wantedBy = ["obsidian.service"];
        before = ["obsidian.service"];
        serviceConfig = {
          Type = "oneshot";
          User = "n8n";
          ExecStart = "${pkgs.xdg-utils}/bin/xdg-mime default obsidian.desktop x-scheme-handler/obsidian";
        };
      };

      # Obsidian under Xvfb
      systemd.services.obsidian = {
        wantedBy = ["multi-user.target"];
        after = ["obsidian-setup-config.service"];
        serviceConfig = {
          User = userName;
          Group = userGroup;
          Environment = "DISPLAY=:5";
          StateDirectory = userName;
          StateDirectoryMode = "0755";
          Restart = "always";
          preStart = ''
            # Enable exit on error
            set -e

            echo "Checking service directories:"
            if ! test -d /obsidian; then
              echo "ERROR: Obsidian vault directory (/obsidian) MISSING - aborting startup"
              exit 1
            fi
            ls -la /obsidian

            echo "Checking secrets dir:"
            if ! test -d /run/container-secrets; then
              echo "ERROR: Secrets directory (/run/container-secrets) MISSING - aborting startup"
              exit 1
            fi
            ls -la /run/container-secrets

            echo "All pre-start checks passed successfully"
          '';
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.xorg.xvfb}/bin/Xvfb :5 -screen 0 1920x1080x24 & sleep 1 && ${pkgs.openbox}/bin/openbox & sleep 1 && exec ${pkgs.obsidian}/bin/obsidian --vault /obsidian --disable-gpu'";
        };
      };

      # VNC bridge for GUI access
      systemd.services.vnc = {
        after = ["obsidian.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          User = userName;
          Group = userGroup;
          Environment = "DISPLAY=:5";
          Restart = "always";
          ExecStartPre = [
            "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.xorg.xset}/bin/xset q >/dev/null 2>&1; do sleep 0.1; done'"
          ];
          ExecStart = "${pkgs.x11vnc}/bin/x11vnc -forever -shared -rfbport ${toString vncPort} -nopw";
        };
      };

      # Configure Openbox to auto-maximize all windows
      systemd.services.obsidian-setup-config = {
        description = "Setup Obsidian configuration";
        wantedBy = ["obsidian.service"];
        before = ["obsidian.service"];
        serviceConfig = {
          Type = "oneshot";
          User = userName;
          Group = userGroup;
          StateDirectory = userName;
          StateDirectoryMode = "0755";
          # Force recreation by adding a version tag
          Environment = "SETUP_VERSION=v8-fix-permissions";
          RemainAfterExit = true;
        };
        script = ''
          # Configure Openbox to auto-maximize all windows
          mkdir -p /var/lib/${userName}/.config/openbox
          cat > /var/lib/${userName}/.config/openbox/rc.xml << EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <openbox_config xmlns="http://openbox.org/3.4/rc">
            <applications>
              <application class="*">
                <maximized>true</maximized>
                <decor>no</decor>
              </application>
            </applications>
            <theme>
              <name>Clearlooks</name>
              <titleLayout>NLIMC</titleLayout>
              <keepBorder>no</keepBorder>
              <animateIconify>no</animateIconify>
            </theme>
          </openbox_config>
          EOF
          chown -R ${userName}:${userGroup} /var/lib/${userName}/.config
        '';
      };

      networking.defaultGateway = defaultGateway;
      networking.nameservers = nameservers;
      networking.firewall = {
        enable = false;
        allowedTCPPorts = [3000 vncPort];
      };
    };
  };
}
