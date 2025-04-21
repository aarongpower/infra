{
  description = "Unified flake for both NixOS and Darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/b024ced1aac25639f8ca8fdfc2f8c4fbd66c48ef";

    # on yggdrasil, using this virsion lix will build but final symlink is still stock nix
    # can't figure out why, so just using latest version
    # can switch to pinned version later when there is a new release
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.lix.follows = "lix";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    concierge = {
      url = "github:aarongpower/nix-concierge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
      # inputs.nixpkgs.follows = "nixpkgs"; # nixpkgs not referenced in proxmox-nixos
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    home-manager,
    fenix,
    nix-darwin,
    agenix,
    compose2nix,
    # sops-nix,
    ...
  } @ inputs: let
    usefulValues = {
      flakeRoot = ./.;
      timezone = "Asia/Jakarta";
    };
    # flakeRoot = ./.;
    overlays = [
      fenix.overlays.default
      # inputs.lix-module.overlays.default
    ];
    sharedModules = [
      ({pkgs, ...}: {nixpkgs.overlays = overlays;})
      inputs.lix-module.nixosModules.default
      # sops-nix.nixosModules.sops
    ];
    linuxModules = [
      agenix.nixosModules.default
      # inputs.vscode-server.nixosModules.default
    ];
    darwinModules = [
      # Other Darwin specific modules
    ];
  in {
    nixosConfigurations = {
      yggdrasil = let
        system = "x86_64-linux";
      in
        nixpkgs.lib.nixosSystem {
          modules =
            linuxModules
            ++ sharedModules
            ++ [
              ./systems/yggdrasil/configuration.nix
              inputs.proxmox-nixos.nixosModules.proxmox-ve
              inputs.sops-nix.nixosModules.sops
              ({...}: let
                generatedContainers = self.packages.x86_64-linux.generate-containers {containersDir = ./systems/yggdrasil/containers;};
                # Debug statement to print the output path
                _ = builtins.trace "generatedContainers output path: ${generatedContainers}" null;
              in {
                imports = [
                  (import "${generatedContainers}/containers.nix")
                ];
              })
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.aaronp = import ./home/yggdrasil.nix;
                home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix usefulValues;};
                home-manager.sharedModules = [
                  inputs.sops-nix.homeManagerModules.sops
                ];
              }
              ({lib, ...}: {
                nixpkgs.overlays = lib.mkAfter [
                  inputs.proxmox-nixos.overlays.x86_64-linux
                ];
              })
            ];
          specialArgs = {inherit inputs usefulValues;};
        };
      vulcan-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          linuxModules
          ++ sharedModules
          ++ [
            nixos-wsl.nixosModules.default
            ./systems/vulcan-nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaronp = import ./home/vulcan-nixos.nix;
              home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix usefulValues;};
            }
          ];
        specialArgs = {inherit inputs usefulValues;};
      };
    };

    darwinConfigurations = {
      astra = nix-darwin.lib.darwinSystem {
        modules =
          darwinModules
          ++ sharedModules
          ++ [
            ./systems/astra/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aaronpower = import ./home/astra.nix;
              home-manager.extraSpecialArgs = {inherit inputs agenix fenix;};
            }
          ];
        specialArgs = {inherit self usefulValues;};
      };
    };
    packages.x86_64-linux.generate-containers = {containersDir}:
      import ./derivations/generate-containers/default.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        compose2nix = compose2nix;
        inherit containersDir;
      };
  };
}
# TAGGED: 2025-04-19T11:07:19.145845519+07:00

