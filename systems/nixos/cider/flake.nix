{
  description = "A flake to install Cider v2.2.0";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # Replace with your desired Nixpkgs channel
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        myAppImage = pkgs.appimageTools.wrapType2 {
          name = "cider220";
          src = ./Cider-linux-appimage-x64.AppImage;
        };
      in
      {
        packages.myAppImage = myAppImage;
        defaultPackage = myAppImage;
      }
    );
}
