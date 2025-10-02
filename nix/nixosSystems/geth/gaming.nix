{ pkgs, config, lib, ... }:

{
    environment.systemPackages = with pkgs; lib.mkAfter [
    ];

    # Enable 32-bit support (required for Steam)
    # hardware.opengl.driSupport32Bit = true;
    # hardware.pulseaudio.support32Bit = true; # If using PulseAudio

    programs.steam = {
      enable = true;
      # remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
      
      # # Enable XWayland support for Steam
      # gamescopeSession.enable = true;
    };

    # Make sure XWayland is enabled
    programs.xwayland.enable = true;
}