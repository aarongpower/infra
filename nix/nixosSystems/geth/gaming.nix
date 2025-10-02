{ pkgs, config, lib, ... }:

{
    environment.systemPackages = with pkgs; lib.mkAfter [
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      
      # Enable XWayland support for Steam
      gamescopeSession.enable = true;
    };

    # Make sure XWayland is enabled
    programs.xwayland.enable = true;
}