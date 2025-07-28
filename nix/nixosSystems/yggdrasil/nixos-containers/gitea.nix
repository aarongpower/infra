{
  config,
  pkgs,
  inputs,
  unstable,
  ...
}: {
  containers.gitea = {
    nixpkgs = inputs.nixpkgs-unstable;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.31/24";
    bindMounts = {
      "/var/lib/gitea" = {
        hostPath = "/tank/gitea";
        isReadOnly = false;
      };
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      services.gitea = {
        enable = true;
        # package = unstable.gitea;
        # user = "root";
        settings = {
          server = {
            # HTTP_PORT = 80;
            DOMAIN = "gitea.sol.rumahindo.net";
          };
        };
      };
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [3000];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [
        {
          address = "192.168.3.31";
          prefixLength = 24;
        }
      ];
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = ["192.168.3.22"];
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  };
}
