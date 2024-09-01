# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./user.nix
    ./docker/overseer/docker-compose.nix
    ./docker/whisparr/docker-compose.nix
    # ./age.nix
    # ../home/nixos.nix
  ];

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  # Allow aaron to run work vm without entering sudo password
  # security.sudo.extraRules = [
  #   {
  #     users = [ "aaron" ];
  #     commands = [ 
  #       {
  #         command = "${pkgs.quickemu} --vm ./windows-11.conf *";
  #         options = [ "NOPASSWD" ];
  #       }
  #     ];
  #   }
  # ];

  security.sudo.extraConfig = ''
    aaronp ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/quickemu --vm ./windows-11.conf *
  '';

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking = {
    useDHCP = false; # Disable DHCP for all interfaces by default
    interfaces = {
      br0 = {
        useDHCP = true; # Enable DHCP specifically for br0
      };
    };
    bridges.br0.interfaces = [ "enp3s0" ]; # Your existing bridge configuration
  };

  # Required to allow qemu to connect VMs to brigde interface
  environment.etc."qemu/bridge.conf".text = ''
    allow br0
  '';

  # Permissions to allow members of netdev group to manage network interfaces
  # Required so I can run a VM that uses a bridged interface
  # services.udev.extraRules = ''
  #   KERNEL=="tun", GROUP="netdev", MODE="0600"
  # '';

  # services.samba = {
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

  # services.samba = {
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

  services.n8n = {
    enable = true;
    webhookUrl = "https://n8n.rumahindo.net/";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."rumahindo.net" = {
      # enableACME = true;
      # forceSSL = true;
      locations."/sonarr" = {
        proxyPass = "http://localhost:8989";
      };
    };
  };

  age.secrets.cloudflare-tunnel-key = {
    file = ../secrets/cloudflare-tunnel-key.age;
    owner = "cloudflared";
    group = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "4dfe26fb-27ae-40c7-a941-11f50f3ed8c3" = {
        credentialsFile = config.age.secrets.cloudflare-tunnel-key.path;
        ingress = {
          "sonarr.rumahindo.net" = "http://localhost:8989";
          "radarr.rumahindo.net" = "http://localhost:7878";
          "sabnzbd.rumahindo.net" = "http://localhost:8080";
          "n8n.rumahindo.net" = "http://localhost:5678";
          "hass.rumahindo.net" = "http://192.168.3.100:8123";
          "plex.rumahindo.net" = "http://localhost:32400";
          "unifi.rumahindo.net" = "https://192.168.2.2";
          "bazarr.rumahindo.net" = "http://localhost:6767";
          "ombi.rumahindo.net" = "http://localhost:5000";
          "overseerr.rumahindo.net" = "http://localhost:5055";
          "whisparr.rumahindo.net" = "http://localhost:6969";
          "prowlarr.rumahindo.net" = "http://localhost:9696";
        };
        originRequest.noTLSVerify = true;
        default = "http_status:404";
      };
    };
  };

  services.deluge.enable = true;
  services.deluge.web.enable = true;

  services.transmission.enable = true;

  services.qbittorrent = {
    enable = true;
  };

  services.bazarr.enable = true;
  services.bazarr.group = "media";

  # services.ombi.enable = true;

  # security.acme.defaults.email = "aarongpower@gmail.com";
  # security.acme.acceptTerms = true;
  
  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    nssmdns4 = true;
    # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    enable = true;
    openFirewall = true;
  };
  # services.samba-wsdd = {
  # # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
  #   enable = true;
  #   openFirewall = true;
  # };


  services.udev.extraRules = ''
    KERNEL=="tun", GROUP="netdev", MODE="0660"
    SUBSYSTEM=="hidraw", GROUP="plugdev", MODE="0660"
  '';
  users.groups.netdev = {};
  # Specify the capabilities for the QEMU binary
  security.wrappers.qemu-system-x86_64 = {
    source = "${pkgs.qemu}/bin/qemu-system-x86_64";
    owner = "root";
    group = "root";
    permissions = "u+rx,g+rx";
    capabilities = "cap_net_admin+ep";
  };

    # Configure network proxy if necessary
  # networking.proxy.default = "http://user:passwo/mnt/bigboy/vm/officerd@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    
    # NIXOS_OZONE_WL = "1"; # https://nixos.wiki/wiki/Wayland - enable Wayland for Chromium and Electron based apps - not using as vscode craps the bed with this enabled
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "aaronp";
      };
      default_session = initial_session;
    };
  };

  # Required to get swaylock to work
  security.pam.services.swaylock = {};

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.greetd}/bin/agreety --cmd $SHELL";
  #       # user = "aaronp";
  #     };
  #   };
  # };

  environment.etc."greetd/environments".text = ''
    hyprland
    zsh
    bash
    nu
  '';

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  # services.xserver = {
  #   enable = true;
  #   xrandrHeads = [ "DP1" "HDMI1" ]; # Enable both screens
  #   screenSection = ''
  #     Option "metamodes" "DP-0: 2560x1440+0+0, HDMI-0: 2560x1440+2560+0"
  #   '';
  #   layout = "us";
  #   xkbVariant = "";

  #   # Enable xmonad
  #   windowManager = {
  #     # default = xmonad;
  #     xmonad = {
  #       enable = true;
  #       enableContribAndExtras = true;
  #       extraPackages = hpkgs: [
  #         hpkgs.xmobar
  #       ];
  #     };
  #   };
  #   # displayManager.sddm.enable = true;
  #   # desktopManager.plasma5.enable = true;
  #   displayManager = {
  #     defaultSession = "none+xmonad";
  #     sddm.enable = true;
  #     # lightdm = {
  #     #   greeters.enso = {
  #     #     enable = true;
  #     #     blur = true;
  #     #   };
  #     # };
  #   };
  # };

  # Configure Wayland
  # programs.sway.enable = true;

  # services.xserver.windowManager.xmonad.config = builtins.readFile ./xmonad.hs;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable automatic discovery of network printers
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  # enable smart cart interface to access yubikey with age-plugin-yubikey
  services.pcscd.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Required for qpaeq to work
  # hardware.pulseaudio.extraConfig = "load-module module-equilizer-sink module-dbus-protocol";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # nixpkgs.overlays = [ fenix.overlays.default ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    haskellPackages.ghc
    haskellPackages.cabal-install
    haskellPackages.haskell-language-server
    mako
    dbus
    bemenu
    wdisplays
    xdg-utils
    xdg-desktop-portal-hyprland
    swaylock-effects
    swayidle
    pulseaudioFull
    tailscale
    polkit_gnome
    # fenix.packages.x86_64-linux.complete.toolchain
    woeusb-ng
    # agenix.packages.x86_64-linux.default
    # wineWowPackages.stable
    # wineWowPackages.waylandFull
    # winetricks
    SDL
    SDL2
    quickemu
    guix
    ngrok
    ripgrep
  ];

  # Enable thunar file manager
  # programs.dolphin.enable = true;
  # programs.xfconf.enable = true;

  services.teamviewer.enable = true;

  # enable jenkins
  services.jenkins = {
    enable = true;
    port = 1234;
  };

  services.nifi = {
    enable = true;
    # listenPort = 667;
    # initUser = "aaron";
    # initPasswordFile = "";
  };
  
  # Enable flatpak
  services.flatpak.enable = true;

  # Enable ZSH
  programs.zsh.enable = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable thunar
  programs.thunar.enable = true;

  # Enable yubikey touch detector
  programs.yubikey-touch-detector.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # TODO: Remove this in the future, required so I can install Obsidian
    # "electron-19.1.9" # TODO: Remove this in the future, required so I can install Etcher
    # "python3.11-apache-airflow-2.7.3"
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Enable Plex
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Enable SABnzbd
  services.sabnzbd.enable = true;
  services.sabnzbd.group = "media";

  # Enable Sonarr
  services.sonarr.enable = true;
  services.sonarr.group = "media";

  # Enable Radarr
  services.radarr.enable = true;
  services.radarr.group = "media";

  services.prowlarr.enable = true;

  # Enable InfluxDB
  services.influxdb2 = {
    enable = true;
  };

  # Enable Tailscale
  services.tailscale.enable = true;
  # configure tailscale as an exit node
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Enable polkit
  security.polkit.enable = true;

  # Enable automatic mounting of USB disks
  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;

  # Enable ZSA keymapp so I can flash my keyboard
  services.keymapp.enable = true;

  # Use Waydroid Android emulator
  virtualisation.waydroid.enable = true;

  # Enable printing service
  # services.printing.enable = true;

  # Install synergy
  # Didn't finish this as currently Wayland doesn't support apps
  # like Synergy that want to take control of input
  # There maybe other ways to do it with 
  # environment.etc."synergy-install.sh".source = "${self}/scripts/synergy-install.sh"
  # environment.etc.

  services.stubby = {
    enable = true;
    settings = pkgs.stubby.passthru.settingsExample // {
      upstream_recursive_servers = [{
        address_data = "1.1.1.1";
        tls_auth_name = "cloudflare-dns.com";
        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "GP8Knf7qBae+aIfythytMbYnL+yowaWVeD6MoLHkVRg=";
        }];
      } {
        address_data = "1.0.0.1";
        tls_auth_name = "cloudflare-dns.com";
        tls_pubkey_pinset = [{
          digest = "sha256";
          value = "GP8Knf7qBae+aIfythytMbYnL+yowaWVeD6MoLHkVRg=";
        }];
      }];
    };
  };

  
}
