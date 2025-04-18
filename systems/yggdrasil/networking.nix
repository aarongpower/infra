{ lib, ... }:

{
  networking = {
    # Enable networking
    networkmanager.enable = true;
  
    hostName = "yggdrasil"; # Define your hostname.
    useDHCP = lib.mkForce true; # Disable DHCP for all interfaces by default
    bridges.br0.interfaces = [ "enp6s0" ];
    interfaces.br0.ipv4.addresses = [
      {
        address = "192.168.3.20";
        prefixLength = 24;
      }
    ];

    vlans = {
      vlan5 = {
        id = 5;
        interface = "br0";
      };
      tauceti = {
        id = 84;
        interface = "br0";
      };
      amritsar = {
        id = 65;
        interface = "br0";
      };
    };

    
    defaultGateway = "192.168.3.1";
    nameservers = [ "192.168.3.22" "1.1.1.1" ];
    
    firewall.enable = false;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 22 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
  };
}
