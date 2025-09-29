{
  pkgs,
  inputs,
  lib,
  config,
  cider220,
  agenix,
  fenix,
  ...
}: {
  imports = [
    ./common-home.nix
    ./common-cli.nix
    ./common-gui.nix
  ];

  # nixpkgs.config.allowUnfree = true;

  home.stateVersion = "23.11";
  home.packages = with pkgs; lib.mkBefore [
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
}
