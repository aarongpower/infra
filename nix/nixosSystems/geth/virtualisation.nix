{
  pkgs,
  config,
  lib,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      swtpm.enable = true;
      runAsRoot = false; # recommended for desktop usage
      vhostUserPackages = [pkgs.virglrenderer pkgs.spice-gtk];
    };
  };
  programs.virt-manager.enable = true;
  users.users.aaronp.extraGroups = lib.mkAfter ["libvirtd" "kvm"];
  environment.systemPackages = with pkgs;
    lib.mkAfter [
      virtio-win
      virt-manager
      spice-gtk
      usbredir
      virglrenderer
      mesa
    ];
  virtualisation.spiceUSBRedirection.enable = true;
}
