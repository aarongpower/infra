{ pkgs, self, agenix, usefulValues, ... }:

{
  pkgs,
  self,
  agenix,
  ...
}: {
  # dedupe nix store
  # nix.extraOptions = ''
  #   auto-optimise-store = true
  # '';

  imports = [
    "${usefulValues.flakeRoot}/ssh/knownHosts.nix"
  ];
  ];

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # agenix.packages.aarch64-darwin.default
    # fenix.packages.aarch64-darwin.complete.toolchain
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # programs.starship.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Aaron's configuration starts here
  security.pam.enableSudoTouchIdAuth = true;

  users.users.aaronpower.home = "/Users/aaronpower";

  # nixpkgs.overlays = [ fenix.overlays.default ];

  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall Dock
    killall SystemUIServer
    killall cfprefsd
  '';

  # system settings
  system.defaults = {
    dock.autohide = true;
    screencapture.location = "~/Pictures/screenshots";
    screencapture.type = "png";
    screensaver.askForPasswordDelay = 10;
    screensaver.askForPassword = true;
    # various macOS settings
    CustomUserPreferences = {
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Download newly available updates in background
        AutomaticDownload = 1;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      "com.apple.print.PrintingPrefs" = {
        # Automatically quit printer app once the print jobs complete
        "Quit When Finished" = true;
      };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      # Turn on app auto-update
      "com.apple.commerce".AutoUpdate = true;
    };
  };

  # disable the startup chime
  system.startup.chime = false;

  # system timezone
  time.timeZone = "Asia/Jakarta";

  # Weekly garbage collection
  # Delete generations older than 30 days
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  # optimise the store periodically
  nix.optimise.automatic = true;
}
