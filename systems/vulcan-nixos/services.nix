{ config, pkgs, lib, ... }:

{
  services = {
    syncthing = {
      enable = true;
      user = "aaronp";
      group = "users";
      dataDir = "/home/aaronp";
      settings = {
        devices = {
          "astra" = { id = "UZIC2YY-JKLMMEQ-CXJU4PW-QV2CWY3-GPD25DH-AS5GZ4Y-QWVUMO7-GWUUJAN"; };
          "vulcan" = { id = "XSHVAS4-XDTLBVW-AM7GCF4-NCLP67Y-FZW6XVF-YU46MRJ-ACQFPPP-AJLFKQ6"; };
        };
        folders = {
          # "dev" = {
          #   path = "/home/aaronp/dev";
          #   devices = [ "astra" "vulcan" ];
          #   # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
          #   ignorePerms = false;
          # };
        };
      };
    };
  };
}
