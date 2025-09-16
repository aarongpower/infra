{pkgs, ...}: {
  users.users.terraform = {
    isNormalUser = true;
    createHome = true;
    description = "Terraform automation user";
    # extraGroups = ["wheel"];
    shell = "${pkgs.zsh}/bin/zsh";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiq6S6RPb9nTROQIFC71uupPe4fY9yvehTppujmQeHj aarongpower@gmail.com"
    ];
  };

  # Symlinks expected by tools that hardcode /usr/bin paths
  systemd.tmpfiles.rules = [
    # coreutils + sudo
    "L+ /usr/bin/tee   - - - - /run/current-system/sw/bin/tee"
    "L+ /usr/bin/mkdir - - - - /run/current-system/sw/bin/mkdir"
    "L+ /usr/bin/mv    - - - - /run/current-system/sw/bin/mv"
    "L+ /usr/bin/chown - - - - /run/current-system/sw/bin/chown"
    "L+ /usr/bin/chmod - - - - /run/current-system/sw/bin/chmod"

    # utils for proxmox ve
    "L /usr/bin/pvesm - - - - /run/current-system/sw/bin/pvesm"
    "L /usr/bin/qm    - - - - /run/current-system/sw/bin/qm"

    # compat symlinks for tools expecting hardcoded paths
    # (looking at you terraform 👁️👁️)
    "L+ /bin/bash   - - - - /run/current-system/sw/bin/bash"
    "L+ /usr/bin/bash - - - - /run/current-system/sw/bin/bash"
  ];


  # environment.systemPackages = lib.mkAfter [
  #   pkgs.bashInteractive # provides bash binary
  #   pkgs.coreutils
  # ];

  # Passwordless sudo for terraform on the exact commands we need
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults:terraform !requiretty
      Defaults secure_path="/run/wrappers/bin:/run/current-system/sw/bin:/usr/bin:/bin"

      # Allow terraform user to run specific commands without password
      terraform ALL=(root) NOPASSWD: /run/current-system/sw/bin/mv /tmp/resolvatron-cloudinit.yaml /var/lib/vz/snippets/resolvatron-cloudinit.yaml
      terraform ALL=(root) NOPASSWD: /run/current-system/sw/bin/chown root\:root /var/lib/vz/snippets/resolvatron-cloudinit.yaml
      terraform ALL=(root) NOPASSWD: /run/current-system/sw/bin/chmod 0644 /var/lib/vz/snippets/resolvatron-cloudinit.yaml
      terraform ALL=(root) NOPASSWD: /usr/bin/pvesm
      terraform ALL=(root) NOPASSWD: /usr/bin/qm
      terraform ALL=(root) NOPASSWD: /run/current-system/sw/bin/tee /var/lib/vz/*
    '';
  };
}
#   "sudo -n mv /tmp/resolvatron-cloudinit.yaml /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
# "sudo -n chown root:root /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
# "sudo -n chmod 0644 /var/lib/vz/snippets/resolvatron-cloudinit.yaml",
# security.sudo.extraRules = [
#   # Allow execution of any command by all users in group sudo,
#   # requiring a password.
#   {
#     groups = ["sudo"];
#     commands = ["ALL"];
#   }
#   # Allow execution of "/home/root/secret.sh" by user `backup`, `database`
#   # and the group with GID `1006` without a password.
#   {
#     users = ["backup" "database"];
#     groups = [1006];
#     commands = [
#       {
#         command = "/home/root/secret.sh";
#         options = ["SETENV" "NOPASSWD"];
#       }
#     ];
#   }
#   # Allow all users of group `bar` to run two executables as user `foo`
#   # with arguments being pre-set.
#   {
#     groups = ["bar"];
#     runAs = "foo";
#     commands = [
#       "/home/baz/cmd1.sh hello-sudo"
#       {
#         command = ''/home/baz/cmd2.sh ""'';
#         options = ["SETENV"];
#       }
#     ];
#   }
# ];
# systemd.tmpfiles.rules = [
#   "d /usr/bin 0755 root root -"
#   "L /usr/bin/tee - - - - ${pkgs.coreutils}/bin/tee"
#   "L /usr/bin/mkdir - - - - ${pkgs.coreutils}/bin/mkdir"
#   "L /usr/bin/pvesm - - - - /run/current-system/sw/bin/pvesm"
#   "L /usr/bin/qm    - - - - /run/current-system/sw/bin/qm"
# ];

