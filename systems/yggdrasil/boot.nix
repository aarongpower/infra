{
  

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # set $FS_UUID to the UUID of the EFI partition
      # extraEntries = ''
      #   menuentry "Windows" {
      #     insmod part_gpt
      #     insmod ntfs
      #     insmod search_fs_uuid
      #     insmod chain
      #     search --fs-uuid --set=root 3e35cd16-f80e-4ebd-a11e-a61efa1f2697
      #     chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      #   }
      # '';
    };
  };
}
