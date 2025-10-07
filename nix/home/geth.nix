{
  pkgs,
  inputs,
  lib,
  config,
  cider220,
  agenix,
  fenix,
  unstable,
  ...
}: {
  imports = [./common-home.nix ./common-cli.nix ./common-gui.nix];

  # nixpkgs.config.allowUnfree = true;

  home.stateVersion = "23.11";
  home.packages = with pkgs;
    lib.mkBefore [
      kdePackages.kate
      microsoft-edge
      direnv
      vlc
      git
      element-desktop
      gh
      geary
      kdePackages.kmail
      fuzzel
      kdePackages.kontact
      thunderbird
      gimp
      libreoffice
      nixfmt-classic
      unstable.whatsapp-for-linux
      unstable.caprine
      unstable.signal-desktop
      nerd-fonts.caskaydia-cove
      evince
      wofi
      reaper
    ];

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

  # Required to get virtualisation working
  # As per https://nixos.wiki/wiki/Virt-manager
  #  dconf.settings = {
  #    "org/virt-manager/virt-manager/connections" = {
  #      autoconnect = ["qemu:///system"];
  #      uris = ["qemu:///system"];
  #    };
  #  };

  programs.waybar.enable = true;
  xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
  xdg.configFile."hypr".source = ./config/hypr;
  # xdg.configFile."hypr/hyprlock.conf".source = ./config/hypr/hyprlock.conf;
  programs.vscode = {
    enable = true;
    package = unstable.vscode;
  };

  services.mako = {
    enable = true;
    settings = {
      layer = "overlay";
      sort = "-time";
      backgroundColor = "#2e3440";
      width = 500;
      height = 200;
      defaultTimeout = 5000;
      borderSize = 2;
      borderColor = "#88c0d0";
      borderRadius = 10;
      margin = "5";
      font = "'Caskaydia Cove' 12";
      output = "HDMI-A-1";
    };
    # extraConfig = ''
    #   [urgency=low]
    #   border-color=#cccccc

    #   [urgency=normal]
    #   border-color=#d08770

    #   [urgency=high]
    #   border-color=#bf616a
    #   default-timeout=0

    #   [category=mpd]
    #   default-timeout=2000
    #   group-by=category
    # '';
  };

  programs.hyprlock.enable = true;
}
