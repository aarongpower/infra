{ pkgs, ... }:

{
  environment = {
    etc = {
      # Required to allow qemu to connect VMs to brigde interface
      "qemu/bridge.conf".text = ''
        allow br0
      '';
      "greetd/environments".text = ''
        hyprland
        zsh
        bash
        nu
      '';
    };

    sessionVariables = {
      # WLR_NO_HARDWARE_CURSORS = "1";
      # NIXOS_OZONE_WL = "1"; # https://nixos.wiki/wiki/Wayland - enable Wayland for Chromium and Electron based apps - not using as vscode craps the bed with this enabled
    };

    systemPackages = with pkgs; [
      haskellPackages.ghc
      haskellPackages.cabal-install
      haskellPackages.haskell-language-server
      mako
      dbus
      bemenu
      wdisplays
      xdg-utils
      xdg-desktop-portal-hyprland
      swaylock-effects
      swayidle
      pulseaudioFull
      tailscale
      polkit_gnome
      # fenix.packages.x86_64-linux.complete.toolchain
      woeusb-ng
      # agenix.packages.x86_64-linux.default
      # wineWowPackages.stable
      # wineWowPackages.waylandFull
      # winetricks
      SDL
      SDL2
      quickemu
      # guix
      ngrok
      ripgrep
    ];
  };
}
