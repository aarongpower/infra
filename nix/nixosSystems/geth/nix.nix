# File: nix.nix
# General nix configuration

{ pkgs, ... }:

{
  nix = {
    extraOptions = ''
      auto-optimise-store = true
    '';

    settings = {
      experimental-features = [ "nix-command" "flakes" ]; # enable flakes
      substituters =
        [ "https://cache.nixos.org/" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        # keep your existing keys; include nix-community if you added it
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [ "root" "aaronp" ];
    };
  };

  # Enable IPv6 preference over IPv4 to avoid delays on dual-stack networks.
  # IndiHome does not support IPv6 yet, so this prevents the downloads from stalling.
  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96  100
  '';

  # Create a nixadmins group for users who should be able to edit /etc/nixos
  users.groups.nixadmins = { members = [ "aaronp" ]; };

  # Ensure /etc/nixos is owned by root:nixadmins, group-writable, and setgid
  # Format: "d <path> <mode> <user> <group> <age> <arg>"
  systemd.tmpfiles.rules = [ "d /etc/nixos 2775 root nixadmins - -" ];

  # Apply ACLs so members of nixadmins can create/edit files now,
  # and so NEW files/dirs automatically inherit rwX for that group.
  system.activationScripts.nixadminsAcls.text = ''
    set -eu
    if [ -d /etc/nixos ]; then
      ${pkgs.acl}/bin/setfacl -R -m g:nixadmins:rwX /etc/nixos
      ${pkgs.acl}/bin/setfacl -R -d -m g:nixadmins:rwX /etc/nixos
    fi
  '';
}
