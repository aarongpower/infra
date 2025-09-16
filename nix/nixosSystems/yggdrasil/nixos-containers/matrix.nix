{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  ipaddress = "192.168.3.38";
  maskbits = 24;
  ipcidr = "${ipaddress}/${toString maskbits}";
  defaultGateway = "192.168.3.1";
  nameservers = ["192.168.3.22"];
  unstable = true;
  nixpkgs =
    if unstable
    then inputs.nixpkgs-unstable
    else inputs.nixpkgs;
  pkgs = import nixpkgs {system = "x86_64-linux";};
in {
  services.cloudflared.tunnels."4dfe26fb-27ae-40c7-a941-11f50f3ed8c3".ingress = lib.mkAfter {
    "matrix.rumahindo.net" = "http://${ipaddress}:8001";
    "chat.rumahindo.net" = "http://${ipaddress}:8080";
  };

  containers.matrix = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = ipcidr;
    nixpkgs = nixpkgs;

    # persist synapse data on host
    bindMounts = {
      "/var/lib/matrix-synapse" = {
        hostPath = "/tank/synapse";
        isReadOnly = false;
      };
      "/var/lib/postgresql" = {
        hostPath = "/tank/matrix-postgres";
        isReadOnly = false;
      };
    };

    config = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        synadm
      ];

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
        initdbArgs = ["--locale=C" "--encoding=UTF8"];
        dataDir = "/var/lib/postgresql/17";

        # Socket only (no TCP). Leave defaults for /run/postgresql.
        settings.listen_addresses = lib.mkForce ""; # empty = local socket
        # settings.unix_socket_directories = "/run/postgresql"; # default

        ensureDatabases = ["matrix-synapse"];
        ensureUsers = [
          {
            name = "matrix-synapse"; # match the Synapse service user
            ensureDBOwnership = true; # owns the "synapse" DB
          }
        ];

        # Peer-auth the service user over the local socket.
        authentication = ''
          local   all   matrix-synapse                 peer
          local   all   all                            peer
        '';
      };

      services.matrix-synapse = {
        enable = true;
        settings = {
          server_name = "matrix.rumahindo.net";
          public_baseurl = "https://matrix.rumahindo.net/";
          experimental_features = {
            msc3575_enabled = true;
          };
          media_store_path = "/var/lib/matrix-synapse/media";
          enable_registration = true;
          registration_requires_token = true;

          # Ensure federation is not restricted by an empty allowlist
          federation_domain_allowlist = lib.mkForce null;
          federation_domain_whitelist = lib.mkForce null;

          # Federation settings
          federation_verify_certificates = true;
          federation_rc_initial_retry_interval = 500; # 500ms
          federation_rc_max_retry_interval = 60000; # 60s

          database = {
            name = "psycopg2";
            args = {
              user = "matrix-synapse";
              database = "matrix-synapse";
              host = "/run/postgresql";
              cp_min = 5;
              cp_max = 10;
            };
          };

          listeners = [
            {
              port = 8000;
              bind_addresses = ["127.0.0.1"]; # avoid direct exposure
              type = "http";
              tls = false;
              x_forwarded = true;
              resources = [
                {
                  names = ["client" "federation"];
                  compress = false;
                }
              ];
            }
          ];
        };
      };

      environment.etc."element-web-config.json".text = ''
        {
          "default_server_config": {
            "m.homeserver": {
              "base_url": "https://matrix.rumahindo.net",
              "server_name": "matrix.rumahindo.net"
            }
          },
          "brand": "Rumah Indo",
          "disable_custom_urls": true,

          "integrations_ui_url": "https://scalar.vector.im/",
          "integrations_rest_url": "https://scalar.vector.im/api",
          "integrations_widgets_urls": [
            "https://scalar.vector.im/_matrix/integrations/v1",
            "https://scalar.vector.im/_matrix/integrations/v2"
          ],

          "setting_defaults": {
            "MessageComposerInput.showStickersButton": true
          }
        }
      '';

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;

        # Element (unchanged)
        virtualHosts."chat.rumahindo.net" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 8080;
            }
          ];
          root = pkgs.element-web;
          extraConfig = "index index.html;";
          locations."= /config.json".extraConfig = ''
            default_type application/json;
            add_header Cache-Control "no-store";
            alias /etc/element-web-config.json;
          '';
        };

        # NEW: front Synapse + well-known
        virtualHosts."matrix.rumahindo.net" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 8001;
            }
          ];

          # Proxy both client and federation APIs
          locations."~ ^(/_matrix|/_synapse)" = {
            proxyPass = "http://127.0.0.1:8000";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header Host $host;

              # Required for federation
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-Server $host;

              # Disable buffering for streaming/long-polling - CRITICAL for Matrix
              proxy_buffering off;
              proxy_request_buffering off;
              proxy_http_version 1.1;

              # Timeouts for long-polling and federation
              proxy_connect_timeout 3600;
              proxy_send_timeout 3600;
              proxy_read_timeout 3600;

              # Increase buffer sizes for federation responses
              proxy_buffer_size 128k;
              proxy_buffers 8 128k;
              proxy_busy_buffers_size 256k;

              # Support large media uploads and federation responses
              client_max_body_size 50M;
              client_body_buffer_size 50M;
            '';
          };

          # Federation discovery endpoint
          locations."/.well-known/matrix/server".extraConfig = ''
            default_type application/json;
            add_header Cache-Control "max-age=3600";
            return 200 '{"m.server":"matrix.rumahindo.net:443"}';
          '';

          # Client discovery endpoint
          locations."/.well-known/matrix/client".extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
            add_header Cache-Control "max-age=3600";
            return 200 '{"m.homeserver":{"base_url":"https://matrix.rumahindo.net"},"m.identity_server":{"base_url":"https://vector.im"}}';
          '';
        };
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [8001 8080]; # Only nginx ports exposed
      };
      networking.nameservers = nameservers;
      networking.defaultGateway = defaultGateway;

      system.stateVersion = "24.11";
    };
  };
}
