{
  description = "NixOS configuration for geth";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

outputs = inputs@{ flake-parts, ... }:
  # https://flake.parts/module-arguments.html
  flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
    imports = [
      # Optional: use external flake logic, e.g.
      # inputs.foo.flakeModules.default
    ];
    flake = {
        nixosConfigurations.geth = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./configuration.nix ];
        };
    };
    systems = [
      # systems for which you want to build the `perSystem` attributes
      "x86_64-linux"
      # ...
    ];
    perSystem = { config, pkgs, ... }: {
      # Recommended: move all package definitions here.
      # e.g. (assuming you have a nixpkgs input)
      # packages.foo = pkgs.callPackage ./foo/package.nix { };
      # packages.bar = pkgs.callPackage ./bar/package.nix {
      #   foo = config.packages.foo;
      # };
    };
  });
}