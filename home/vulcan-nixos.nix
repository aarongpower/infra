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
  ];

  home.stateVersion = "23.11";
  home.packages = let
    commonCliPackages = import ./common-pkgs-cli.nix {inherit pkgs inputs fenix;};
    commonGuiPackages = import ./common-pkgs-cli.nix {inherit pkgs inputs fenix;};
    localPackages = with pkgs; [
    ];
  in
    localPackages ++ commonCliPackages ++ commonGuiPackages;

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
}
