{
  pkgs,
  config,
  lib,
  ...
}: {
  # Use systemd-networkd, disable NetworkManager
  networking.useNetworkd = true;
  networking.networkmanager.enable = false;

  # (Recommended) Use systemd-resolved for DNS
  services.resolved.enable = true;

  # Bridge device br0
  systemd.network.netdevs."br0".netdevConfig = {
    Kind = "bridge";
    Name = "br0";
  };

  # Put the physical NIC into the bridge
  systemd.network.networks."10-enp2s0" = {
    matchConfig.Name = "enp2s0";
    networkConfig.Bridge = "br0";
  };

  # Assign static IP + gateway + DNS to the bridge (host’s IP lives here)
  systemd.network.networks."10-br0" = {
    matchConfig.Name = "br0";
    address = ["10.71.1.11/24"];
    gateway = ["10.71.1.1"];
    dns = ["192.168.3.22"];
    linkConfig.RequiredForOnline = "routable";
  };

  # (Optional) If you run the NixOS firewall, it will apply on br0
  # networking.firewall.enable = true;
}
