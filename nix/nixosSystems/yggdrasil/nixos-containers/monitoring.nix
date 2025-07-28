{
  config,
  pkgs,
  unstable,
  inputs,
  lib,
  ...
}: {
  services.cloudflared.tunnels."4dfe26fb-27ae-40c7-a941-11f50f3ed8c3".ingress = lib.mkAfter {
    "grafana.rumahindo.net" = "http://192.168.3.29:3000";
  };
  # sops.secrets.mimir_s3_secret_access_key = {
  #   owner = "grafana";
  #   group = "grafana";
  # };
  containers.monitoring = {
    nixpkgs = inputs.nixpkgs-unstable;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.29/24";
    bindMounts = {
      "/var/lib/grafana" = {
        hostPath = "/tank/monitoring/grafana";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [];
      # services.mimir = {
      #   enable = true;
      #   configuration = {
      #     common = {
      #       backend = "s3";
      #       s3 = {
      #         endpoint = "192.168.3.34:3900";
      #         region = "gamping";
      #         bucket_name = "mimir";
      #         secret_access_key = config.sops.secrets.mimir_s3_secret_access_key.path;
      #       };
      #     };
      #   };
      # };
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "0.0.0.0";
          };
        };
      };
      networking.firewall = {
        enable = false;
        allowedTCPPorts = [
        ];
      };
      networking.defaultGateway = "192.168.3.1"; # adjust as needed
      networking.nameservers = ["192.168.3.22"]; # adjust as needed
      system.stateVersion = "24.11";
    };
  };
}
