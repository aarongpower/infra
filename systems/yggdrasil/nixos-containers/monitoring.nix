{
  config,
  pkgs,
  unstable,
  inputs,
  ...
}: {
  containers.monitoring = {
    nixpkgs = inputs.nixpkgs-unstable;
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.29/24";
    bindMounts = {
      "/var/lib/prometheus2" = {
        hostPath = "/tank/monitoring/prometheus";
        isReadOnly = false;
      };
      "/var/lib/grafana" = {
        hostPath = "/tank/monitoring/grafana";
        isReadOnly = false;
      };
      "/var/lib/uptime-kuma" = {
        hostPath = "/tank/monitoring/uptime-kuma";
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
      # };
      # services.loki = {
      #   enable = true;
      # };
      services.grafana = {
        enable = true;
        settings = {
          # grafana.ini
          server = {
            http_addr = "0.0.0.0";
            # root_url = "http://localhost:3000";
            # serve_from_sub_path = true;
          };
          # auth.anonymous = {
          #   enabled = true;
          #   org_role = "Viewer";
          # };
          # dashboards.default = {
          #   prometheus = {
          #     datasource = "Prometheus";
          #     folder = "";
          #     type = "file";
          #     options = {
          #       path = "/var/lib/grafana/dashboards/default";
          #     };
          #   };
          # };
        };
        provision.datasources.settings = {
          apiVersion = 1;

          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:9090";
            }
          ];
        };
      };
      networking.firewall = {
        enable = false;
        allowedTCPPorts = [
          3001 # uptime-kuma
          8080 # gatus
          9090 # prometheus
        ];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [
        {
          address = "192.168.3.29";
          prefixLength = 24;
        }
      ];
      networking.defaultGateway = "192.168.3.1"; # adjust as needed
      networking.nameservers = ["192.168.3.22"]; # adjust as needed
      system.stateVersion = "24.11";
    };
  };
}
