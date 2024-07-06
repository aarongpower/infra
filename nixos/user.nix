{ pkgs, windows-vm, ... }:

{
  users.groups.bigboyntfs = {
    gid = 1000;
  };
  users.groups.media = {
    gid = 1001;
  };
  users.groups.vfio = {}; # vfio group

  users.users.aaronp = {
    isNormalUser = true;
    shell = "${pkgs.nushell}/bin/nu";
    description = "Aaron Power";
    extraGroups = [ "networkmanager" "wheel" "bigboyntfs" "input" "libvirtd" "qemu-libvirtd" "vfio" "plugdev" "libvirt" "kvm" "netdev"];
    packages = with pkgs; [

    ];
  };
}
