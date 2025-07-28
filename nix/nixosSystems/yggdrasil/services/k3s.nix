{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  system = "x86_64-linux";
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  # Import the unstable k3s module explicitly to use new options (autoDeployCharts).
  # autoDeployCharts is not in 24.11 but should be in future stable relases
  # Must disable the stable module to avoid conflicts (options/modules are evaluated separately from packages).
  # disabledModules = [ "services/cluster/k3s/default.nix" ];
  # imports = [
  #   "${inputs.nixpkgs-unstable}/nixos/modules/services/cluster/k3s/default.nix"
  # ];

  services.k3s = {
    enable = true;
    role = "server";
    # package = unstable.k3s;
    # autoDeployCharts = {
    #   longhorn = {
    #     name = "longhorn";
    #     repo = "https://charts.longhorn.io";
    #     version = "v1.8.1";
    #     targetNamespace = "longhorn-system";
    #     createNamespace = true;
    #     values = {
    #       defaultSettings = {
    #         defaultDataPath = "/tank/longhorn_storage";
    #       };
    #     };
    #   };
    # };
  };

  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
  ];

  # Use a bind mount or direct path, NO symlinks for Longhorn's storage:
  fileSystems."/var/lib/longhorn" = {
    device = "/tank/longhorn_storage";
    options = ["bind"];
  };

  # environment.etc."longhorn".source = "/mnt/longhorn_storage";
  systemd.tmpfiles.rules = [
    # "L+ /var/lib/longhorn - - - - /tank/longhorn_storage"
    "L+ /usr/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm" # required for longhorn to access iscsiadm
  ];

  # required to get longhorn to access iscsi binaries on NixOS
  systemd.services.k3s.serviceConfig = {
    Environment = [
      "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/bin:/usr/bin:/sbin:/usr/sbin"
    ];
  };
}
