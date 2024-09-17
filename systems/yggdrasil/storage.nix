{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "56797fd6";

  boot.zfs.extraPools = [ "tank" ];

  # fileSystems."/media" = {
  #   device = "tank/media";
  #   fsType = "zfs";
  # };
}
