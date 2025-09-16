{
  pkgs,
  inputs,
  ...
}: {
  environment = {
    etc = {
      # Required to allow qemu to connect VMs to brigde interface
      # "qemu/bridge.conf".text = ''
      #   allow br0
      # '';
      # "greetd/environments".text = ''
      #   hyprland
      #   zsh
      #   bash
      #   nu
      # '';
    };

    sessionVariables = {
      # WLR_NO_HARDWARE_CURSORS = "1";
      # NIXOS_OZONE_WL = "1"; # https://nixos.wiki/wiki/Wayland - enable Wayland for Chromium and Electron based apps - not using as vscode craps the bed with this enabled
    };

    systemPackages = with pkgs; [
      # nixVersions.stable
      cdrkit
      nodejs
      git
    ];
  };
}
