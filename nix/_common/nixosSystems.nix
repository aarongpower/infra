{
  inputs,
  nixpkgs ? inputs.nixpkgs,
  globals,
  root ? globals.flakeRoot,
  lib,
  self,
  linuxModules,
  sharedModules,
  overlays,
  ...
}: let
  # all entries under nixosSystems/
  systemDirs = builtins.attrNames (builtins.readDir (root + "/nixosSystems"));

  # keep only those that have a configuration.nix
  hosts =
    builtins.filter
    (name: builtins.pathExists "${root}/nixosSystems/${name}/system.nix")
    systemDirs;
in
  nixpkgs.lib.genAttrs hosts (host: let
    systemParams =
      import "${root}/nixosSystems/${host}/system.nix" {inherit globals;};
    thisSystemPath = "${root}/nixosSystems/${host}";
    containers = "${thisSystemPath}/containers";
    pkgs = import inputs.nixpkgs {
      system = systemParams.system;
      config = {allowUnfree = true;};
    };
    unstable = import inputs.nixpkgs-unstable {
      system = pkgs.system;
      config.allowUnfree = true;
    };
  in
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs globals nixpkgs;};
      modules =
        linuxModules
        ++ sharedModules
        ++ [
          # {lix.settings.experimental-features = ["nix-command" "flakes"];}
          "${thisSystemPath}/configuration.nix"
          inputs.sops-nix.nixosModules.sops
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Import the home configuration for the specific user on this system
            home-manager.users.aaronp = import "${root}/home/${host}.nix";
            home-manager.extraSpecialArgs = {inherit inputs globals unstable;};
            # Use a deterministic timestamp for backups, derived from flake metadata.
            # Produces e.g. backup-20250928T084456
            home-manager.backupFileExtension = "backup-${globals.buildTimestamp}";
          }
        ]
        ++ lib.optional systemParams.useProxmox
        inputs.proxmox-nixos.nixosModules.proxmox-ve
        ++ lib.optional systemParams.useProxmox {
          nixpkgs.overlays =
            lib.mkAfter [inputs.proxmox-nixos.overlays.x86_64-linux];
        }
        ++ lib.optional systemParams.useContainers ({...}: let
          generatedContainers =
            self.packages.x86_64-linux.generate-containers-function containers;
        in {imports = [(import "${generatedContainers}/containers.nix")];});
    })
