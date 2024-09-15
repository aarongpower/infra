{ config, pkgs, lib, ... }:

{
  programs = {
    # hyprland = {
    #   enable = true;
    #   xwayland.enable = true;
    # };

    zsh = {
      enable = true;
    };

    # steam = {
    #   enable = true;
    # };

    # virt-manager = {
    #   enable = true;
    # };

    # thunar = {
    #   enable = true;
    # };

    yubikey-touch-detector = {
      enable = true;
    };
  };
}
