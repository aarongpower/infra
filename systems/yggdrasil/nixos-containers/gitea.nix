{ config, pkgs ... }:

{
  containers.gitea = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.31/24";
    enableTun = true; # this is required so that zerotierone can use the tun interface

    config = { config, pkgs, ... }: {
       networking.firewall.allowedUDPPorts = [ 9993 ];
      # networking.enableIPv4Forwarding = true;
      # environment.systemPackages = [ pkgs.zerotierone ];

      services.zerotierone = {
        enable = true;
        # package = unstable.zerotierone;
        joinNetworks = [ "d3ecf5726d5c1c83" ];
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.31";
        prefixLength = 24;
      }];
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = [ "192.168.3.22" ];
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  };
}
