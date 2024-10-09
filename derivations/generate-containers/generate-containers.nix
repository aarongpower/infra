let
  # compose2nix = builtins.getFlake "github:aksiksi/compose2nix";
  # nixpkgs = builtins.getFlake "nixpkgs";
  # pkgs = import nixpkgs {
  #   system = "x86_64-linux"; # Adjust the system as needed
  # };
  # lib = pkgs.lib;
in
  {
    pkgs,
    compose2nix,
    containersDir,
  }:
    pkgs.stdenv.mkDerivation {
      pname = "containers-config";
      version = "1.0";
      src = ./.;

      # Include compose2nix as a build input
      buildInputs = [compose2nix.packages.x86_64-linux.default];

      buildCommand = ''
        cp -r $src $TMP/source
        chmod +x $TMP/source/build.sh
        $TMP/source/build.sh ${containersDir}
      '';
    }
