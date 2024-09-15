{ pkgs, inputs, lib, config, cider220, agenix, fenix, ... }:

let
  edgeWrapped = pkgs.stdenv.mkDerivation {
    name = "microsoft-edge-wrapped";
    buildInputs = [ pkgs.microsoft-edge pkgs.makeWrapper ];
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.microsoft-edge}/bin/microsoft-edge $out/bin/microsoft-edge
      wrapProgram $out/bin/microsoft-edge --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  };
in
{
  imports = [
    ./common-home.nix
  ];

  home.stateVersion = "23.11";
  home.packages = let
    commonPackages = import ./common-pkgs.nix { inherit pkgs inputs fenix; };
    localPackages = with pkgs; [
      # Development Tools
      cider220

      # Productivity
      obsidian
      kate
      vscode
      zotero
      _1password-gui
      onedrive
      onedrivegui
      wl-clipboard
      # agenix

      # Media
      vlc

      # Web Browsers
      firefox
      brave
      # microsoft-edge
      # Wrapped Microsoft Edge
      # enables the use of the Wayland backend
      edgeWrapped

      # Email Clients
      thunderbird
      nom
      cloudflared

      lshw
      nix-index
      syncthing
      unetbootin
      pavucontrol
      mako
      waybar
      syncthingtray
      wttrbar
      hyprpaper
      swayimg
      whatsapp-for-linux
      caprine-bin
      obs-studio
      todoist-electron
      polkit
      polkit_gnome
      # quickemu - moved to system
      quickgui
      spice-gtk
      tesseract
      wlr-randr
      # (nixpkgs-pinned-looking-glass-b6.legacyPackages.x86_64-linux.looking-glass-client)
      looking-glass-client
      usbutils
      usbredir
      # gnome.gnome-calendar
      # etcher
      socat
      # xclip
      cider220.packages.x86_64-linux.myAppImage
      influxdb2
      # fenix.packages.x86_64-linux.complete.toolchain
      # xsel
      wl-clipboard-x11
      nil
      # woeusb-ng
      kubo
      anytype
      libgcc
      virt-viewer
      ollama
      parsec-bin
      tor-browser
      blender
      slurp
      grim
      moonlight-embedded
      (pkgs.writeShellScriptBin "work" ''
        exec /mnt/bigboy/vm/work/launch
      '')
      ledger-live-desktop
      ganttproject-bin
      # anydesk
      ncdu
      element-desktop
  ];
  in localPackages ++ commonPackages;

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = (builtins.readFile ../nixos/hypr/hyprland.conf);
  };

  services.mako = {
    enable = true;
    layer="overlay";
    sort="-time";
    backgroundColor="#2e3440";
    width = 500;
    height = 200;
    defaultTimeout = 5000;
    borderSize = 2;
    borderColor="#88c0d0";
    borderRadius = 10;
    margin = "5";
    font="'Caskaydia Cove' 12";
    output="HDMI-A-1";
    extraConfig = ''
      [urgency=low]
      border-color=#cccccc
      
      [urgency=normal]
      border-color=#d08770
      
      [urgency=high]
      border-color=#bf616a
      default-timeout=0

      [category=mpd]
      default-timeout=2000
      group-by=category
    '';
  };

  # programs.ssh.matchBlocks = [
  #   {
  #     host = "aaron-desktop.rumahindo.net";
  #     proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
  #   }
  # ];

  # Swayidle config
  # xdg.configFile."swayidle/config".text = ''
  #   timeout 300 'swaylock -f'
  #   timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
  #   before-sleep 'swaylock -f'
  # '';

  xdg.configFile."swayidle/config".text = ''
    timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
  '';

  # Swaylock config
  # swaylock --clock --indicator --grace 10 --indicator-caps-lock --color 000000 --scaling stretch --image /etc/nixos/images/icons.jpeg
  xdg.configFile."swaylock/config".text = ''
    clock
    indicator
    indicator-caps-lock
    color=000000
    scaling=stretch
    image=/etc/nixos/nixos/images/icons.jpeg
    ignore-empty-password
  '';

  # Hyprpaper config
  xdg.configFile."hypr/hyprpaper.conf".source = ../nixos/hypr/hyprpaper.conf;

  # Waybar config
  xdg.configFile."waybar/style.css".source = ../nixos/waybar/style.css;
  xdg.configFile."waybar/config".source = ../nixos/waybar/waybar.conf;

  # Required to get virtualisation working
  # As per https://nixos.wiki/wiki/Virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
