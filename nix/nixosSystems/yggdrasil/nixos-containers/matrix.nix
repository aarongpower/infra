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

    # persist synapse, postgres, and bridge data on host
    bindMounts = {
      "/var/lib/matrix-synapse" = {
        hostPath = "/tank/synapse";
        isReadOnly = false;
      };
      "/var/lib/postgresql" = {
        hostPath = "/tank/matrix-postgres";
        isReadOnly = false;
      };
      "/var/lib/mautrix-meta" = {
        hostPath = "/tank/mautrix-meta";
        isReadOnly = false;
      };
    };

    config = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [synadm];

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
        initdbArgs = ["--locale=C" "--encoding=UTF8"];
        dataDir = "/var/lib/postgresql/17";
        settings.listen_addresses = lib.mkForce ""; # socket-only

        ensureDatabases = ["matrix-synapse" "mautrix_meta"];
        ensureUsers = [
          {
            name = "matrix-synapse";
            ensureDBOwnership = true;
          }
          {
            name = "mautrix_meta";
            ensureDBOwnership = true;
          }
        ];

        authentication = ''
          local   all   matrix-synapse   peer
          local   all   mautrix_meta     peer
          local   all   all              peer
        '';
      };

      services.matrix-synapse = {
        enable = true;
        settings = {
          server_name = "matrix.rumahindo.net";
          public_baseurl = "https://matrix.rumahindo.net/";
          experimental_features = {msc3575_enabled = true;};
          media_store_path = "/var/lib/matrix-synapse/media";
          enable_registration = true;
          registration_requires_token = true;

          federation_domain_allowlist = lib.mkForce null;
          federation_domain_whitelist = lib.mkForce null;

          federation_verify_certificates = true;
          federation_rc_initial_retry_interval = 500;
          federation_rc_max_retry_interval = 60000;

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
              bind_addresses = ["127.0.0.1"];
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

          # Append the double-puppet appservice registration we create below
          app_service_config_files = lib.mkAfter ["/etc/matrix-appservices/doublepuppet.yaml"];
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
          "setting_defaults": { "MessageComposerInput.showStickersButton": true }
        }
      '';

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;

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

        virtualHosts."matrix.rumahindo.net" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 8001;
            }
          ];

          locations."~ ^(/_matrix|/_synapse)" = {
            proxyPass = "http://127.0.0.1:8000";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-Server $host;
              proxy_buffering off;
              proxy_request_buffering off;
              proxy_http_version 1.1;
              proxy_connect_timeout 3600;
              proxy_send_timeout 3600;
              proxy_read_timeout 3600;
              proxy_buffer_size 128k;
              proxy_buffers 8 128k;
              proxy_busy_buffers_size 256k;
              client_max_body_size 50M;
              client_body_buffer_size 50M;
            '';
          };

          locations."/.well-known/matrix/server".extraConfig = ''
            default_type application/json;
            add_header Cache-Control "max-age=3600";
            return 200 '{"m.server":"matrix.rumahindo.net:443"}';
          '';

          locations."/.well-known/matrix/client".extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
            add_header Cache-Control "max-age=3600";
            return 200 '{"m.homeserver":{"base_url":"https://matrix.rumahindo.net"},"m.identity_server":{"base_url":"https://vector.im"}}';
          '';
        };
      };

      # --- Messenger bridge (mautrix-meta, megabridge) ---
      services.mautrix-meta.instances.messenger = {
        enable = true;
        dataDir = "/var/lib/mautrix-meta/messenger";
        registerToSynapse = true;

        settings = {
          # REQUIRED in megabridge: pick the service
          network = {
            mode = "messenger"; # other valid: "facebook", "facebook-tor", "instagram"
          };

          homeserver = {
            software = "standard";
            # Bridge talks to Synapse via the local listener
            address = "http://127.0.0.1:8000";
            domain = "matrix.rumahindo.net";
          };

          appservice = {
            # REQUIRED id for registration
            id = "mautrix-meta-messenger";
            # Where Synapse pushes transactions (also written to registration url)
            address = "http://127.0.0.1:29323";
            hostname = "127.0.0.1";
            port = 29323;

            # Bridge state DB (Postgres)
            database = {
              type = "postgres";
              uri = "postgresql:///mautrix_meta?host=/run/postgresql";
            };

            bot = {
              username = "messengerbot";
              displayname = "Messenger Bridge";
            };
          };

          # Permissions are required
          bridge = {
            permissions = {
              "@aaron:matrix.rumahindo.net" = "admin"; # change if your MXID is different
              "*" = "user";
            };

            # E2EE defaults
            encryption = {
              allow = true;
              default = true;
              require = true;
            };
          };

          # New megabridge double-puppet config (top-level key)
          double_puppet = {
            # Map your homeserver domain to the DP token we put in the extra appservice
            secrets = {"matrix.rumahindo.net" = "as_token:CHANGEME_DP_AS_TOKEN";};
          };
        };
      };

      # Extra appservice registration for automatic double-puppeting (null URL).
      # Only Synapse needs to read this file.
      environment.etc."matrix-appservices/doublepuppet.yaml".text = ''
        id: doublepuppet
        url:
        as_token: CHANGEME_DP_AS_TOKEN
        hs_token: unused-but-random-please-change
        sender_localpart: unused-but-random-please-change
        rate_limited: false
        namespaces:
          users:
            - regex: '@.*:matrix\.rumahindo\.net'
              exclusive: false
      '';

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [8001 8080]; # appservice stays on loopback
      };
      networking.nameservers = nameservers;
      networking.defaultGateway = defaultGateway;

      system.stateVersion = "24.11";
    };
  };
}
