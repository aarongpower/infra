{ pkgs, inputs, lib, config, cider220, agenix, fenix, ... }:

{
  imports = [
    ./common-home.nix
  ];

  home.stateVersion = "23.11";
  home.packages = let
    commonPackages = import ./common-pkgs.nix { inherit pkgs inputs fenix; };
    localPackages = with pkgs; [
      # cloudflared
      lshw
      nix-index
      # syncthing
      nil
      ncdu
      helix
      # inputs.compose2nix.packages.${pkgs.system}.default
      inputs.concierge.packages.${pkgs.system}.default
      bat
      htop
      tree
  ];
  in localPackages;

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
