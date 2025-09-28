{ pkgs, config, lib, ...}:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;
  users.users.aaronp.extraGroups = lib.mkAfter [ "libvirtd" "kvm" ];
  environment.systemPackages = with pkgs; lib.mkAfter [ virtio-win ];
}
