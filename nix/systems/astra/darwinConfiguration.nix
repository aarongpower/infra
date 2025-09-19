{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  linuxModules,
  sharedModules,
  home-manager,
  agenix,
  fenix,
  compose2nix,
  globals,
  self,
  ...
}: let
  system = "aarch64-darwin";
  systemName = "astra";
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  unstableModulesPath = "${inputs.nixpkgs-unstable}/nixos/modules";
  thisSystemPath = "${globals.flakeRoot}/systems/${systemName}";
  containers = "${thisSystemPath}/containers";
  configuration = import "${thisSystemPath}/configuration.nix";
  home = import "${globals.flakeRoot}/home/${systemName}.nix";
in
  inputs.nix-darwin.lib.darwinSystem {
    modules =
      linuxModules
      ++ sharedModules
      ++ [
        #
        configuration
        inputs.sops-nix.darwinModules.sops
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.aaronpower = home;
          home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix globals;};
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ];
    specialArgs = {inherit inputs globals unstable self;};
  }
