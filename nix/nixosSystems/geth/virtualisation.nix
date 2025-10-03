{
  pkgs,
  config,
  lib,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;   # <-- switch from qemu_kvm to qemu_full
      ovmf.enable = true;
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  # Ensure Mesa/DRI stack is on (newer NixOS uses hardware.graphics.*)
  hardware.graphics.enable = true;
  # (optional but handy) hardware.graphics.enable32Bit = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; lib.mkAfter [
    virtio-win
    virt-manager
    spice-gtk
    usbredir
    virglrenderer
  ];

  virtualisation.spiceUSBRedirection.enable = true;

  users.users.aaronp.extraGroups = lib.mkAfter [ "libvirtd" "kvm" ];
}

