{
  config,
  pkgs,
  inputs,
  unstable,
  ...
}: {
  containers.opencloud = {
    nixpkgs = inputs.nixpkgs-unstable;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.33/24";
    bindMounts = {
      "/var/lib/opencloud" = {
        hostPath = "/tank/opencloud/state";
        isReadOnly = false;
    };
    };
 
    config = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        # we want to use the unstable version of the module
        # 2025-07-05 opencloud is not available in the 24.11 or 25.05 stable branches
        "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/opencloud.nix"
      ];

      # override default to unstable so opencloud can find its dependencies
      # nixpkgs.pkgs = unstable;

      networking.firewall.allowedUDPPorts = [9200];

      services.opencloud = {
        enable = true;
        # package = unstable.opencloud;
        address = "192.168.3.33";
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [
        {
          address = "192.168.3.33";
          prefixLength = 24;
        }
      ];
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = ["192.168.3.22"];
      system.stateVersion = "24.11";
    };
  };
}
