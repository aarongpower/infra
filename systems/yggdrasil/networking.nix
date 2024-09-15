{ lib, ... }:

{
  networking = {
    # Enable networking
    networkmanager.enable = true;
  
    hostName = "yggdrasil"; # Define your hostname.
    useDHCP = lib.mkForce true; # Disable DHCP for all interfaces by default
    interfaces = {
      # br0 = {
      #   useDHCP = true; # Enable DHCP specifically for br0
      # };
    };

    # bridges.br0.interfaces = [ "enp3s0" ]; # Your existing bridge configuration
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:passwo/mnt/bigboy/vm/officerd@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain"

    firewall.enable = false;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 22 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
  };
}
