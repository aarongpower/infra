{ config, pkgs, lib, usefulValues, ... }:

{
  imports = [
    ./overseerr/docker-compose.nix
    # ./containers/actual/docker-compose.nix
    ./openbudgeteer/docker-compose.nix
    ./scrypted/docker-compose.nix
    ./babybuddy/docker-compose.nix
    ./gramps/docker-compose.nix
    # ./grocy/docker-compose.nix
  ];
}
