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
    copyparty.url = "github:9001/copyparty";
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
    linger = {
      url = "github:mindsbackyard/linger-flake";
      inputs.flake-utils.follows = "flake-utils";
    };
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix?ref=main";
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
    opnix = {
      url = "github:mrjones2014/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    organist = {
      url = "github:nickel-lang/organist";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pihole = {
      url = "github:mindsbackyard/pihole-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.linger.follows = "linger";
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
    # Provide a deterministic timestamp from flake metadata for reuse.
    # Prefer self.lastModifiedDate (YYYYMMDDHHMMSS), fall back to formatting epoch seconds.
    globals = let
      raw = self.lastModifiedDate or "";
      ts = if builtins.stringLength raw >= 14 then
        "${builtins.substring 0 8 raw}T${builtins.substring 8 6 raw}"
      else if self ? lastModified then
        inputs.nixpkgs.lib.formatTime "%Y%m%dT%H%M%S" self.lastModified
      else
        "";
    in {
      flakeRoot = ./.;
      repoRoot = ./..;
      timezone = "Asia/Jakarta";
      buildTimestamp = ts; # e.g., 20250928T084456
    };
    overlays = [inputs.fenix.overlays.default];
    sharedModules = [
      ({pkgs, ...}: {nixpkgs.overlays = overlays;})
      inputs.lix-module.nixosModules.default
      inputs.opnix.nixosModules.default
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
      darwinConfigurations."astra" = import "${globals.flakeRoot}/systems/astra/darwinConfiguration.nix" {
        inherit self inputs globals linuxModules sharedModules;
        agenix = inputs.agenix;
        compose2nix = inputs.compose2nix;
        fenix = inputs.fenix;
        home-manager = inputs.home-manager;
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
