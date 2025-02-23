{ config, pkgs, lib, ... }:

{
  containers.blocky = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.22/24";
    config = { config, pkgs, ... }: {
      services.blocky = {
        enable = true;
        settings = {
          ports.dns = 53;
          upstreams = {
            groups.default = [ 
              "tcp-tls:9.9.9.9"
              "tcp-tls:149.112.112.112"
              "tcp-tls:1.1.1.1"
              "tcp-tls:1.0.0.1"
            ];
          };
          blocking = {
            blackLists = {
              general = [ 
                "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/multi.txt"
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              ];
              fakenews = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
              ];
              porn = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts"
              ];
              gambling = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"
              ];
            };
            clientGroupsBlock = {
              default = [
                "general"
                "fakenews"
                "porn"
                "gambling"
              ];
            };
          };
          bootstrapDns = [
            "tcp-tls:9.9.9.9"
          ];
        };
      };
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.22";
        prefixLength = 24;
      }];
      networking.defaultGateway = "192.168.3.1";  # adjust as needed
      networking.nameservers = [ "9.9.9.9" ];  # adjust as needed
      system.stateVersion = "24.11";
    };
  };
  containers.blocky-test = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.23/24";
    config = { config, pkgs, ... }: {
      services.blocky = {
        enable = true;
        settings = {
          ports.dns = 53;
          upstreams = {
            groups.default = [ 
              "tcp-tls:9.9.9.9"
              "tcp-tls:149.112.112.112"
              "tcp-tls:1.1.1.1"
              "tcp-tls:1.0.0.1"
            ];
          };
          blocking.blackLists = {
            general = [ "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/multi.txt" ];
          };
        };
      };
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.23";
        prefixLength = 24;
      }];
      networking.defaultGateway = "192.168.3.1";  # adjust as needed
      networking.nameservers = [ "192.168.3.1" ];  # adjust as needed
      system.stateVersion = "24.11";
    };
  };
  containers.nsd = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.24/24";
    config = { config, pkgs, ... }: {
      services.nsd = {
        enable = true;
        zones."rumahindo.lan".data = ''
          @ SOA ns1.rumahindo.lan. aarongpower.gmail.com (
            2025022201 ; serial (use YYYYMMDDNN format)
            3600       ; refresh (1h)
            600        ; retry (10m)
            86400      ; expire (24h)
            3600       ; minimum (1h)
          )
              IN NS ns1.rumahindo.lan

          ns1 IN A 192.168.3.23

          yggdrasil IN A 192.168.3.20
          '';
      };
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.24";
        prefixLength = 24;
      }];
      networking.defaultGateway = "192.168.3.1";  # adjust as needed
      networking.nameservers = [ "9.9.9.9" ];  # adjust as needed
      system.stateVersion = "24.11";
    };
  };
}
