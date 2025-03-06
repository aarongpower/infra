{ lib, ... }:

{
  networking = {
    hostName = "vulcan-nixos"; # Define your hostname.
    nameservers = [ "192.168.3.22" ];
    search = [ "rumahindo.lan" ];
  };
}
