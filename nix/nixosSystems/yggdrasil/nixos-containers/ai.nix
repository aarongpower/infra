{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}: let
  ipaddress = "192.168.3.26";
  maskbits = 24;
  idcidr = "${ipaddress}/${toString maskbits}";
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
    "ai.rumahindo.net" = "http://${ipaddress}:8080";
  };
  containers.ai = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = idcidr;
    bindMounts = {
      "/var/lib/private/open-webui" = {
        hostPath = "/tank/containers/open-webui/state";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      services.open-webui = {
        enable = true;
        openFirewall = true;
        host = ipaddress;
        environment = {
          WEBUI_AUTH_TRUSTED_EMAIL_HEADER = "Cf-Access-Authenticated-User-Email";
        };
      };
      networking.firewall = {
        enable = true;
        # allowedTCPPorts = [3838];
      };
      networking.defaultGateway = defaultGateway; # adjust as needed
      networking.nameservers = nameservers; # adjust as needed
      system.stateVersion = "24.11";
    };
  };
}
