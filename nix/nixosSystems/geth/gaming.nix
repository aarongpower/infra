{ pkgs, config, lib, ... }:

{
    environment.systemPackages = with pkgs; lib.mkAfter [
      steam
    ];
}