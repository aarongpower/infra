{
  pkgs,
  windows-vm,
  ...
}: {
  # users.groups.vfio = {}; # vfio group
  users.groups.netdev = {};
  users.groups.media = {
    members = ["sonarr" "radarr" "plex" "sabnzdb"];
    gid = 1001;
  };

  users.users.nobody = {
    extraGroups = ["media"];
  };

  users.users.aaronp = {
    isNormalUser = true;
    shell = "${pkgs.zsh}/bin/zsh";
    description = "Aaron Power";
    extraGroups = ["networkmanager" "wheel" "input" "libvirtd" "qemu-libvirtd" "vfio" "plugdev" "libvirt" "kvm" "netdev"];
    packages = with pkgs; [
    ];
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiq6S6RPb9nTROQIFC71uupPe4fY9yvehTppujmQeHj aarongpower@gmail.com"
      ];
    };
  };

  security.sudo.extraRules = [
    {
      users = ["aaronp"];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
        {
          command = "/etc/profiles/per-user/aaronp/bin/garage";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
