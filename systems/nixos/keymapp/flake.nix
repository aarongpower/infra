{
  description = "A flake for keymapp";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.keymapp-udev = import ./modules/keymapp-udev.nix;

    packages.x86_64-linux.keymapp = import ./pkgs/keymapp/default.nix {
      inherit (nixpkgs) lib stdenv fetchurl libusb1 webkitgtk gtk3;
    };
  };
}


