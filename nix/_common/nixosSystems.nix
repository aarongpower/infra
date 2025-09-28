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
  systemDirs =
    builtins.attrNames (builtins.readDir (root + "/nixosSystems"));

  # keep only those that have a configuration.nix
  hosts =
    builtins.filter
    (name: builtins.pathExists "${root}/nixosSystems/${name}/system.nix")
    systemDirs;
in
  nixpkgs.lib.genAttrs hosts (host: let
    systemParams = import "${root}/nixosSystems/${host}/system.nix" {inherit globals;};
    thisSystemPath = "${root}/nixosSystems/${host}";
    containers = "${thisSystemPath}/containers";
    pkgs = import inputs.nixpkgs {
      system = systemParams.system;
      config = {allowUnfree = true;};
    };
  in
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs globals nixpkgs;};
      modules =
        linuxModules
        ++ sharedModules
        ++ [
          "${thisSystemPath}/configuration.nix"
          inputs.sops-nix.nixosModules.sops
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Import the home configuration for the specific user on this system
            home-manager.users.aaronp = import "${root}/home/${host}.nix";
            home-manager.extraSpecialArgs = {inherit inputs globals;};
            # Use the flake's last modified date as a deterministic timestamp for backups.
            # Produces e.g. backup-20250928T084456
            home-manager.backupFileExtension = let
              raw = self.lastModifiedDate or "";
              ts = if builtins.stringLength raw >= 14 then
                "${builtins.substring 0 8 raw}T${builtins.substring 8 6 raw}"
              else raw;
            in "backup-${ts}";
          }
        ]
        ++ lib.optional systemParams.useProxmox inputs.proxmox-nixos.nixosModules.proxmox-ve
        ++ lib.optional systemParams.useProxmox {nixpkgs.overlays = lib.mkAfter [inputs.proxmox-nixos.overlays.x86_64-linux];}
        ++ lib.optional systemParams.useContainers ({...}: let
          generatedContainers = self.packages.x86_64-linux.generate-containers-function containers;
        in {
          imports = [
            (import "${generatedContainers}/containers.nix")
          ];
        });
    })
