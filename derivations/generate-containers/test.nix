# derivations/compose2nix/default.nix
{pkgs ? import <nixpkgs> {}}: let
  compose2nixDerivation = import ./generate-containers.nix {
    inherit pkgs;
    containersDir = ./test/containers;
  };
in
  compose2nixDerivation
