{
  config,
  pkgs,
  lib,
  usefulValues,
  ...
}: {
  services = {
    # vscode-server.enable = true;

    timesyncd = {
      enable = true;
      servers = [
        "0.id.pool.ntp.org"
        "1.id.pool.ntp.org"
        "2.id.pool.ntp.org"
        "3.id.pool.ntp.org"
      ];
    };

    proxmox-ve = {
      enable = true;
      ipAddress = "192.168.3.20";
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    n8n = {
      enable = true;
      webhookUrl = "https://n8n.rumahindo.net/";
    };
    node-red = {
      enable = true;
      withNpmAndGcc = true;
    };

    ttyd = {
      enable = true;
      port = 16900;
      writeable = true;
      interface = "127.0.0.1";
      # username = "aaronp";
    };

    # Note that in yggdrasil/environment.nix there is a symlink that points
    # /var/lib/syncthing to /tank/syncthing
    # I want to keep the sync folders and config in the tank
    # but there seems to be a bug whereby if I change the dataDir, it tries to
    # put the syncthing database in the nix store
    syncthing = {
      enable = true;
      # dataDir = /tank/syncthing;
      # configDir = /var/lib/syncthing/.config/syncthing;
      settings = {
        devices = {
          "astra" = {id = "UZIC2YY-JKLMMEQ-CXJU4PW-QV2CWY3-GPD25DH-AS5GZ4Y-QWVUMO7-GWUUJAN";};
          "vulcan" = {id = "XSHVAS4-XDTLBVW-AM7GCF4-NCLP67Y-FZW6XVF-YU46MRJ-ACQFPPP-AJLFKQ6";};
          "vulcan-nixos" = {id = "34UHDDE-NOBJ6S3-Q6DUHNR-WVNBAOK-W66AY4Y-C7YLVQM-O567LFR-4EAKNAT";};
          "old-laptop" = {id = "CBG357V-5I2REZE-7XSYYHS-LSMDBLH-75PPIUZ-3PJGKNQ-CWANQSU-BVXWZA7";};
        };
        folders = {
          "/var/lib/syncthing/dev" = {
            label = "dev";
            id = "cv3rm-nqhlu";
            devices = ["astra" "vulcan"];
          };
          "/var/lib/syncthing/aaron_sync" = {
            label = "aaron_sync";
            id = "default";
            devices = ["astra" "vulcan"];
          };
          "/var/lib/syncthing/laptop-backup" = {
            label = "laptop-backup";
            id = "laptop-backup";
            devices = ["old-laptop"];
          };
        };
        gui = {
          insecureSkipHostcheck = true; # required to allow cloudflared tunnel
        };
      };
    };
  };
}
