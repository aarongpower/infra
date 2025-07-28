{
  config,
  pkgs,
  globals,
  lib,
  ...
}: {
  users.groups.cloudflared = {};
  age.secrets.cloudflare-tunnel-key = {
    file = "${globals.flakeRoot}/secrets/cloudflare-tunnel-key.age";
    owner = "root";
    group = "cloudflared";
    mode = "0440";
  };
  systemd.services.cloudflared.serviceConfig.SupplementaryGroups = ["cloudflared"];
  services.cloudflared = {
    enable = true;
    tunnels = {
      "4dfe26fb-27ae-40c7-a941-11f50f3ed8c3" = {
        credentialsFile = config.age.secrets.cloudflare-tunnel-key.path;
        ingress = lib.mkBefore {
          "sonarr.rumahindo.net" = "http://192.168.3.27:8989";
          "radarr.rumahindo.net" = "http://192.168.3.27:7878";
          "sabnzbd.rumahindo.net" = "http://192.168.3.27:8080";
          "n8n.rumahindo.net" = "http://localhost:5678";
          "hass.rumahindo.net" = "http://192.168.3.21:8123";
          "plex.rumahindo.net" = "http://192.168.3.27:32400";
          "unifi.rumahindo.net" = "https://192.168.2.2";
          "bazarr.rumahindo.net" = "http://192.168.3.27:6767";
          "overseerr.rumahindo.net" = "http://localhost:5055";
          "prowlarr.rumahindo.net" = "http://192.168.3.27:9696";
          "scrypted.rumahindo.net" = "https://localhost:10443";
          "babybuddy.rumahindo.net" = "http://localhost:11606";
          "yggdrasil.rumahindo.net" = "http://localhost:16900";
          "nodered.rumahindo.net" = "http://localhost:1880";
          "suggestarr.rumahindo.net" = "http://localhost:5000";
          "syncthing.rumahindo.net" = "http://localhost:8384";
          "whisparr.rumahindo.net" = "http://localhost:6969";
          "vaultwarden.rumahindo.net" = "http://192.168.3.25";
          "chat.rumahindo.net" = "http://192.168.3.26:8080";
          "jellyfin.rumahindo.net" = "http://192.168.3.27:8096";
          "yggdrasil.earth.rumahindo.net" = "ssh://192.168.3.20:22";
          "gitea.rumahindo.net" = "http://192.168.3.31:3000";
          "mikrotik.rumahindo.net" = "http://192.168.3.11";
        };
        originRequest.noTLSVerify = true;
        default = "http_status:404";
      };
    };
  };

  # Allow the cloudflare CA when authenticating
  services.openssh.settings.TrustedUserCAKeys = let
    caFile = pkgs.writeTextFile {
      name = "cloudflare-ssh-ca.pub";
      text = builtins.readFile "${globals.flakeRoot}/certs/cloudflare-ssh-ca.pub";
    };
  in "${caFile}";
}
