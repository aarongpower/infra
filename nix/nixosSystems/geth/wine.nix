{ pkgs, config, lib, ... }:

{
#   hardware.graphics = {
#     # enable = true;
#     enable32bit = true;  # For Wine
#   };

  environment.systemPackages = with pkgs; lib.mkAfter [
    # Wine (both 32/64-bit). “full” adds extras like vkd3d, faudio, etc.
    wineWowPackages.full

    # Handy tools
    winetricks
    mangohud   # FPS/metrics overlay if you want it
    # Optional GUIs (choose one or both)
    bottles
    lutris
  ];
}