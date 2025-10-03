{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    lib.mkAfter [
    ];

  # Enable 32-bit support (required for Steam)
  # hardware.opengl.driSupport32Bit = true;
  # hardware.pulseaudio.support32Bit = true; # If using PulseAudio

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };
}
