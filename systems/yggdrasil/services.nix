{ config, pkgs, lib, ... }:

{
  # nixpkgs.overlays = [
  #   (self: super: {
  #     python3Packages = super.python3Packages // {
  #       aiohttp = super.python3Packages.aiohttp.overrideAttrs (oldAttrs: {
  #         doCheck = false;
  #       });
  #     };
  #   })
  # ];

  services = {
    # keymapp.enable = true;

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
    
   #  n8n = {
   #    enable = true;
   #    webhookUrl = "https://n8n.rumahindo.net/";
   #  };

   cloudflared = {
      enable = true;
      tunnels = {
        "4dfe26fb-27ae-40c7-a941-11f50f3ed8c3" = {
          credentialsFile = config.age.secrets.cloudflare-tunnel-key.path;
          ingress = {
            "sonarr.rumahindo.net" = "http://localhost:8989";
            "radarr.rumahindo.net" = "http://localhost:7878";
            "sabnzbd.rumahindo.net" = "http://localhost:8080";
            # "n8n.rumahindo.net" = "http://localhost:5678";
            "hass.rumahindo.net" = "http://192.168.3.100:8123";
            "plex.rumahindo.net" = "http://localhost:32400";
            "unifi.rumahindo.net" = "https://192.168.2.2";
            "bazarr.rumahindo.net" = "http://localhost:6767";
            # "ombi.rumahindo.net" = "http://localhost:5000";
            "overseerr.rumahindo.net" = "http://localhost:5055";
            # "whisparr.rumahindo.net" = "http://localhost:6969";
            "prowlarr.rumahindo.net" = "http://localhost:9696";
          };
          originRequest.noTLSVerify = true;
          default = "http_status:404";
        };
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
