{ pkgs, config, lib, ... }:

{
    environment.systemPackages = with pkgs; lib.mkAfter [
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Optional: for Steam Remote Play
      dedicatedServer.openFirewall = true; # Optional: for Source Dedicated Server
    };
}