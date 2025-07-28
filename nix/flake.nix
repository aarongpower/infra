{
  description = "Unified flake for both NixOS and Darwin systems";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    concierge = {
      url = "github:aarongpower/nix-concierge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    organist = {
      url = "github:nickel-lang/organist";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
      # inputs.nixpkgs.follows = "nixpkgs"; # nixpkgs not referenced in proxmox-nixos
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tf-ncl = {
      url = "github:tweag/tf-ncl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, ...} @ inputs: let
    globals = {
      flakeRoot = ./.;
      repoRoot = ./..;
      timezone = "Asia/Jakarta";
    };
    overlays = [inputs.fenix.overlays.default];
    sharedModules = [
      ({pkgs, ...}: {nixpkgs.overlays = overlays;})
      inputs.lix-module.nixosModules.default
    ];
    linuxModules = [
      inputs.agenix.nixosModules.default
    ];
    # mkNixosConfigurations = import ./_common/nixosSystems.nix {
    #   inherit inputs globals self;
    #   lib = inputs.nixpkgs.lib;
    # };
  in
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          system = "${system}";
          config.allowUnfree = true;
        };
        nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
        overlays = [inputs.fenix.overlays.default];
      in {
        devShells.default = import ./_devshells/default.nix {
          inherit inputs globals pkgs system unstable overlays;
        };
      }
    )
    // {
      globals = globals;
      nixosConfigurations = import ./_common/nixosSystems.nix {
        inherit inputs globals self overlays linuxModules sharedModules;
        lib = inputs.nixpkgs.lib;
      };
      darwinConfigurations = import "${globals.flakeRoot}/systems/astra/darwinConfiguration.nix" {
        inherit self inputs globals linuxModules sharedModules;
        nixpkgs = inputs.nixpkgs;
        nixpkgs-unstable = inputs.nixpkgs-unstable;
        # add any other required arguments
      };

      packages.x86_64-linux = {
        generate-containers-function = containersDir:
          inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage ./derivations/generate-containers/default.nix {
            compose2nix = inputs.compose2nix;
            inherit containersDir;
          };

        # Default example with a fixed path for tests
        generate-containers = inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage ./derivations/generate-containers/default.nix {
          compose2nix = inputs.compose2nix;
          containersDir = ./derivations/generate-containers/test/containers;
        };
      };
    };
}
