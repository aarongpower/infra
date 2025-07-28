# derivations/compose2nix/default.nix
let
  compose2nix = builtins.getFlake "github:aksiksi/compose2nix";
in
{pkgs ? import <nixpkgs> {}}: let
  compose2nixDerivation = import ./default.nix {
    inherit pkgs;
    inherit compose2nix;
    containersDir = ./test/containers;
  };
in
  compose2nixDerivation
