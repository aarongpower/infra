{ config, pkgs, lib, inputs, unstable,... }:

{
  containers.librenms = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.30/24";
    enableTun = true; # this is required so that zerotierone can use the tun interface

    config = { config, pkgs, ... }: {
       # networking.firewall.allowedUDPPorts = [ 9993 ];
      # networking.enableIPv4Forwarding = true;
      # environment.systemPackages = [ pkgs.zerotierone ];

      services.librenms = {
        enable = true;
        package = unstable.librenms;
      };
      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.30";
        prefixLength = 24;
      }];
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # enable forwarding so packets may return
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = [ "192.168.3.22" ];
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  };

}
