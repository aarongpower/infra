{ config, pkgs, ... }:

{
  containers.ansible = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.198.3.30/24";
    bindMounts = {
      "/repo-base" = {
        hostPath = "/tank/ansible/repo";
        isReadOnly = false;
      };
    };
    config = {config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [ ansible ];
      services.openssh.enable = true;
      networking.useDHCP = false;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];
      };
      networking.interfaces.eth0.ipv4.addresses = [{
        address = "192.168.3.30";
        prefixLength = 24;
      }];
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = [ "192.168.3.22" ];
      system.stateVersion = "24.11";

      # services.bindfs = {
      #   enable = true;
      #   mounts = [
      #     {
      #       source = "/repo-base";
      #       target = "/repo";
      #       options = [
      #         "--force-user=aaronp"
      #         "--force-group=users"
      #       ];
      #     }
      #   ];
      # };

      users.users.aaronp = {
        isNormalUser = true;
        openssh = {
          authorizedKeys.keys = [
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiq6S6RPb9nTROQIFC71uupPe4fY9yvehTppujmQeHj aarongpower@gmail.com"
          ];
        };
      };
    };
  };
}
