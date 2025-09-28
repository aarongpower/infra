{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Desktop environments
  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.niri.enable = true;

  security.polkit.enable = true;

  # Enable polkit for privilege elevation in GUI apps
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    after    = [ "graphical-session.target" ];
    partOf   = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  # Various XDG portals for Wayland apps
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gnome  # helps niri; see note below
      xdg-desktop-portal-gtk
    ];
  };

  # explicitly use seahorse as security manager
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  # Wayland-friendly Electron/Chromium apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Enable dconf so we can set GNOME keybindings declaratively
  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable GNOME Keyring integration with PAM (login, gdm)
  security.pam.services = {
    login.enableGnomeKeyring = true;
    gdm.enableGnomeKeyring = true;
    gdm-password.enableGnomeKeyring = true;
  };

  # various system packages to support the above
  environment.systemPackages = with pkgs; lib.mkAfter [
    gnome-tweaks
    # gnome-extensions-app
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    rofi-wayland       # launcher
    rofi-power-menu     # optional: power menu script (run: rofi -show power-menu -modi power-menu)
    polkit_gnome
    ironbar
    gnome-backgrounds
    swaybg
    gnome-online-accounts
    gnome-online-accounts-gtk
    libsecret
    seahorse
    waybar
  ];
}