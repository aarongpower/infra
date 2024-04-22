{
  description = "Unified flake for both NixOS and Darwin systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    cider220 = {
      url = "path:./nixos/cider";
    };
    
    keymapp = {
      url = "path:./nixos/keymapp";
    };
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    concierge = {
      url = "github:aarongpower/nix-concierge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fenix, keymapp, cider220, nix-darwin, agenix, ... }:
  let
    overlays = [ 
      fenix.overlays.default
    ];
    sharedModules = [
      ({ pkgs, ... }: { nixpkgs.overlays = overlays; })
    ];
    linuxModules = [
      ./nixos/configuration.nix
      keymapp.nixosModules.keymapp-udev
    ];
    darwinModules = [
      ./astra/configuration.nix
      # Other Darwin specific modules
    ];
  in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = sharedModules ++ linuxModules ++ [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.aaronp = import ./home/nixos.nix;
            home-manager.extraSpecialArgs = { inherit cider220 agenix fenix; };
          }
        ];
        # specialArgs = { inherit home-manager; };
      }; 
    };

    darwinConfigurations = {
      astra = nix-darwin.lib.darwinSystem {
        modules = darwinModules ++ sharedModules ++ [
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.aaronpower = import ./home/astra.nix;
            home-manager.extraSpecialArgs = { inherit agenix fenix; };
          }
        ];
        specialArgs = { inherit self; };
      };
    };
  };
}
