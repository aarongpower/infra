{ config, pkgs, lib, inputs, ... }:

{
  services = {
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

    plex = {
      enable = true;
      openFirewall = true;
    };

    sabnzbd = {
      enable = true;
      group = "media";
    };

    sonarr = {
      enable = true;
      group = "media";
    };

    radarr = {
      enable = true;
      group = "media";
    };

    prowlarr = {
      enable = true;
    };

    bazarr = {
      enable = true;
      group = "media";
    };

   #  influxdb2 = {
   #    enable = true;
   #  };
    
    # tailscale = {
    #   enable = true;
    # };
    
    n8n = {
      enable = true;
      webhookUrl = "https://n8n.rumahindo.net/";
    };

    # grocy = {
    #   enable = true;
    #   hostName = "grocy.rumahindo.net";
    #   nginx.enableSSL = false;
    # };

    node-red = {
      enable = true;
      withNpmAndGcc = true;
    };

   cloudflared = {
      enable = true;
      tunnels = {
        "4dfe26fb-27ae-40c7-a941-11f50f3ed8c3" = {
          credentialsFile = config.age.secrets.cloudflare-tunnel-key.path;
          ingress = {
            "sonarr.rumahindo.net" = "http://localhost:8989";
            "radarr.rumahindo.net" = "http://localhost:7878";
            "sabnzbd.rumahindo.net" = "http://localhost:8080";
            "n8n.rumahindo.net" = "http://localhost:5678";
            "hass.rumahindo.net" = "http://192.168.3.21:8123";
            "plex.rumahindo.net" = "http://localhost:32400";
            "unifi.rumahindo.net" = "https://192.168.2.2";
            "bazarr.rumahindo.net" = "http://localhost:6767";
            # "ombi.rumahindo.net" = "http://localhost:5000";
            "overseerr.rumahindo.net" = "http://localhost:5055";
            "prowlarr.rumahindo.net" = "http://localhost:9696";
            "actual.runahindo.net" = "http://localhost:5006";
            "scrypted.rumahindo.net" = "https://localhost:10443";
            "babybuddy.rumahindo.net" = "http://localhost:11606";
            "yggdrasil.rumahindo.net" = "http://localhost:16900";
            "gramps.rumahindo.net" = "http://localhost:8888";
            # "grocy.rumahindo.net" = "http://localhost:80";
            "nodered.rumahindo.net" = "http://localhost:1880";
            "suggestarr.rumahindo.net" = "http://localhost:5000";
            "syncthing.rumahindo.net" = "http://localhost:8384";
            "ospos.rumahindo.net" = "http://localhost:80";
            "whisparr.rumahindo.net" = "http://localhost:6969";
            "vaultwarden.rumahindo.net" = "http://192.168.3.25";
            "chat.rumahindo.net" = "http://192.168.3.26:8080";
          };
          originRequest.noTLSVerify = true;
          default = "http_status:404";
        };
      };
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
          "astra" = { id = "UZIC2YY-JKLMMEQ-CXJU4PW-QV2CWY3-GPD25DH-AS5GZ4Y-QWVUMO7-GWUUJAN"; };
          "vulcan" = { id = "XSHVAS4-XDTLBVW-AM7GCF4-NCLP67Y-FZW6XVF-YU46MRJ-ACQFPPP-AJLFKQ6"; };
          "vulcan-nixos" = { id = "34UHDDE-NOBJ6S3-Q6DUHNR-WVNBAOK-W66AY4Y-C7YLVQM-O567LFR-4EAKNAT"; };
        };
        folders = {
          "/var/lib/syncthing/dev" = {
            label = "dev";
            id = "cv3rm-nqhlu";
            devices = [ "astra" "vulcan" ];
          };
          "/var/lib/syncthing/aaron_sync" = {
            label = "aaron_sync";
            id = "default";
            devices = [ "astra" "vulcan" ];
          };
        };
        gui = {
          insecureSkipHostcheck = true; # required to allow cloudflared tunnel
        };
      };
    };


    samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
          workgroup = WORKGROUP
          server role = standalone server
          dns proxy = no
          vfs objects = catia fruit streams_xattr

          pam password change = yes
          map to guest = bad user
          usershare allow guests = yes
          create mask = 0664
          force create mode = 0664
          directory mask = 0775
          force directory mode = 0775
          follow symlinks = yes
          load printers = no
          printing = bsd
          printcap name = /dev/null
          disable spoolss = yes
          strict locking = no
          aio read size = 0
          aio write size = 0
          vfs objects = acl_xattr catia fruit streams_xattr
          inherit permissions = yes

          # Security
          client ipc max protocol = SMB3
          client ipc min protocol = SMB2_10
          client max protocol = SMB3
          client min protocol = SMB2_10
          server max protocol = SMB3
          server min protocol = SMB2_10

          # Time Machine
          fruit:delete_empty_adfiles = yes
          fruit:time machine = yes
          fruit:veto_appledouble = no
          fruit:wipe_intentionally_left_blank_rfork = yes
          fruit:posix_rename = yes
          fruit:metadata = stream
        '';

      shares = {
        # "Time Capsule" = {
        #   path = "/pool/samba/timemachine";
        #   browseable = "yes";
        #   "read only" = "no";
        #   "inherit acls" = "yes";

        #   # Authenticate ?
        #   # "valid users" = "melias122";

        #   # Or allow guests
        #   "guest ok" = "yes";
        #   "force user" = "nobody";
        #   "force group" = "nogroup";
        # };
        media = {
          path = "/tank/media";
          browseable = "yes";
          "read only" = "no";

          # This is public, everybody can access.
          "guest ok" = "yes";
          "force user" = "nobody";
          "force group" = "media";

          "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
          "delete veto files" = "yes";
        };

        software = {
          path = "/tank/images";
          browseable = "yes";
          "read only" = "no";

          # This is public, everybody can access.
          "guest ok" = "yes";
          "force user" = "nobody";
          "force group" = "media";

          "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
          "delete veto files" = "yes";
        };

        downloads = {
          path = "/tank/downloads";
          browseable = "yes";
          "valid users" = "aaronp";
          "read only" = "no";
          writeable = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force user" = "aaronp";
          "force group" = "media";

          # make it private
          "guest ok" = "no";

          "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
          "delete veto files" = "yes";

          # honor FACLs
          "vfs objects" = "acl_xattr";
        };
        # melias122 = {
        #   path = "/pool/samba/melias122";
        #   browseable = "yes";
        #   "read only" = "no";

        #   # Make this private
        #   "guest ok" = "no";
        #   "valid users" = "melias122";

        #   "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        #   "delete veto files" = "yes";
        # };

        other = {
          path = "/tank/other";
          browseable = "yes";
          "valid users" = "aaronp";
          "read only" = "no";
          writeable = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force user" = "aaronp";
          "force group" = "media";

          # make it private
          "guest ok" = "no";

          "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
          "delete veto files" = "yes";

          # honor FACLs
          "vfs objects" = "acl_xattr";
        };
        # melias122 = {
        #   path = "/pool/samba/melias122";
        #   browseable = "yes";
        #   "read only" = "no";

        #   # Make this private
        #   "guest ok" = "no";
        #   "valid users" = "melias122";

        #   "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        #   "delete veto files" = "yes";
        # };
      };
    };

    # deluge = {
    #   enable = true;
    #   web.enable = true;
    # };

    # transmission = {
    #   enable = true;
    # };

    # # automatic mounting of USB drives
    # udisks2 = {
    #   enable = true;
    #   mountOnMedia = true;
    # };

    # # avahi is for printer discovery on the network
    # avahi = {
    #   publish.enable = true;
    #   publish.userServices = true;
    #   # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    #   nssmdns4 = true;
    #   # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    #   enable = true;
    #   openFirewall = true;
    # };

    # jenkins = {
    #   enable = true;
    #   port = 1234;
    # };
    
    # nifi = {
    #   enable = true;
    #   # listenPort = 667;
    #   # initUser = "aaron";
    #   # initPasswordFile = "";
    # };

    # teamviewer = {
    #   enable = true;
    # };

    # flatpak = {
    #   enable = true;
    # };

    # greetd = {
    #   enable = true;
    #   settings = rec {
    #     initial_session = {
    #       command = "${pkgs.hyprland}/bin/Hyprland";
    #       user = "aaronp";
    #     };
    #     default_session = initial_session;
    #   };
    # };

    # enable smart cart interface to access yubikey with age-plugin-yubikey
    # pcscd = {
    #   enable = true;
    # };

    # enable CUPS to print documents
    # printing = {
    #   enable = true;
    # };

    # pipewire = {
    #   enable = true;
    #   alsa.enable = true;
    #   alsa.support32Bit = true;
    #   pulse.enable = true;
    #   # If you want to use JACK applications, uncomment this
    #   #jack.enable = true;

    #   # use the example session manager (no others are packaged yet so this is enabled by default,
    #   # no need to redefine it in your config for now)
    #   #media-session.enable = true;
    # };

    # udev.extraRules = ''
    #   KERNEL=="tun", GROUP="netdev", MODE="0660"
    #   SUBSYSTEM=="hidraw", GROUP="plugdev", MODE="0660"
    # '';

    # stubby = {
    #   enable = true;
    #   settings = pkgs.stubby.passthru.settingsExample // {
    #     upstream_recursive_servers = [{
    #       address_data = "1.1.1.1";
    #       tls_auth_name = "cloudflare-dns.com";
    #       tls_pubkey_pinset = [{
    #         digest = "sha256";
    #         value = "GP8Knf7qBae+aIfythytMbYnL+yowaWVeD6MoLHkVRg=";
    #       }];
    #     } {
    #       address_data = "1.0.0.1";
    #       tls_auth_name = "cloudflare-dns.com";
    #       tls_pubkey_pinset = [{
    #         digest = "sha256";
    #         value = "GP8Knf7qBae+aIfythytMbYnL+yowaWVeD6MoLHkVRg=";
    #       }];
    #     }];
    #   };
    # };

    # samba = {
    #   enable = true;
    #   shares = {
    #     media = {
    #       path = "/mnt/bigboy/media";
    #       browseable = "yes";
    #       "read only" = "no";
    #       "guest ok" = "yes";
    #       "create mask" = "0644";
    #       "directory mask" = "0755";
    #     };
    #   };
    # };

    # samba = {
    #   package = pkgs.samba4Full;
    #   # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
    #   # Required for samba to register mDNS records for auto discovery 
    #   # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
    #   enable = true;
    #   openFirewall = true;
    #   shares.media = {
    #     path = "/mnt/bigboy/media";
    #     writable = "true";
    #     comment = "Media library";
    #     "read only" = "no";
    #     "guest ok" = "yes";
    #     "create mask" = "0644";
    #     "directory mask" = "0755";
    #   };
    #   extraConfig = ''
    #     workgroup = WORKGROUP
    #     server string = smbnix
    #     netbios name = smbnix
    #     security = user 
    #     #use sendfile = yes
    #     #max protocol = smb2
    #     # note: localhost is the ipv6 localhost ::1
    #     hosts allow = 192.168.3. 127.0.0.1 localhost
    #     hosts deny = 0.0.0.0/0
    #     guest account = nobody
    #     map to guest = bad user
    #   '';
    #   # extraConfig = ''
    #   #   server smb encrypt = required
    #   #   # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
    #   #   server min protocol = SMB3_00
    #   # '';
    # };

    
  };
}
