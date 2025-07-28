{
  inputs,
  globals,
  self,
  ...
}: let
  system = "x86_64-linux";
  systemName = "vulcan-nixos";
  thisSystemPath = "${globals.flakeRoot}/systems/${systemName}";
  containers = "${thisSystemPath}/containers";
  home = import "${globals.flakeRoot}/home/${systemName}.nix" {
    inherit inputs globals pkgs;
    # add other specialArgs if needed
  };
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in [
  ./configuration.nix
  inputs.sops-nix.nixosModules.sops
  ({...}: let
    generatedContainers = self.packages.x86_64-linux.generate-containers {
      containersDir = containers;
    };

    # this prints the real store path and still yields the derivation
    generatedContainersDbg =
      builtins.trace
      ("generate-containers → " + toString generatedContainers.outPath)
      generatedContainers;
  in {
    imports = [
      # use the traced value here
      (import "${generatedContainersDbg}/containers.nix")
    ];
  })
  home-manager.nixosModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.aaronp = home;
    home-manager.extraSpecialArgs = {inherit inputs agenix fenix compose2nix globals;};
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  }
]
