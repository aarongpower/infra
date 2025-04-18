{
  config,
  pkgs,
  ...
}: {
  containers.dnsmasq = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.3.32/24";
    bindMounts = {
      "/tftproot" = {
        hostPath = "/tank/misc/tftp-root";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      systemd.tmpfiles.rules = [
        # type  path          mode  user    group   age  arg
        "d /tftproot          0777  nobody  nogroup -"
        "Z /tftproot          0777  nobody  nogroup -"
      ];

      networking.firewall.allowedUDPPorts = [
        67 # DHCP
        69 # TFTP
      ];

      networking.firewall.allowedTCPPorts = [
        445 # smb
      ];

      # networking.enableIPv4Forwarding = true;
      # environment.systemPackages = [ pkgs.zerotierone ];

      services.dnsmasq = {
        enable = true;
        settings = {
          enable-tftp = true;
          tftp-root = "/tftproot";
        };
        # package = unstable.zerotierone;
        # joinNetworks = [ "d3ecf5726d5c1c83" ];
      };

      services.samba = {
        enable = true;
        settings = {
          global = {
            workgroup = "WORKGROUP";
            "server Role" = "standalone server";
            "dns proxy" = "no";
            "vfs objects" = "acl_xattr catia fruit streams_xattr";

            "pam password change" = "yes";
            "map to guest" = "bad user";
            "usershare allow guests" = "yes";
            "create mask" = "0664";
            "force create mode" = "0664";
            "directory mask" = "0775";
            "force directory mode" = "0775";
            "follow symlinks" = "yes";
            "load printers" = "no";
            "printing" = "bsd";
            "printcap name" = "/dev/null";
            "disable spoolss" = "yes";
            "strict locking" = "false";
            "aio read size" = 0;
            "aio write size" = 0;
            "inherit permissions" = "yes";

            # Security
            "client ipc max protocol" = "SMB3";
            "client ipc min protocol" = "SMB2_10";
            "client max protocol" = "SMB3";
            "client min protocol" = "SMB2_10";
            "server max protocol" = "SMB3";
            "server min protocol" = "SMB2_10";
          };
          tftproot = {
            path = "/tftproot";
            browseable = "no";
            "read only" = "no";
            writeable = "yes";

            # This is public, everybody can access.
            "guest ok" = "yes";
            "force user" = "nobody";
            "force group" = "nogroup";

            "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
            "delete veto files" = true;
          };
        };
      };

      users.groups.nogroup = {
      };

      users.users.nobody = {
        extraGroups = ["nogroup"];
      };

      networking.useDHCP = false;
      networking.interfaces.eth0.ipv4.addresses = [
        {
          address = "192.168.3.32";
          prefixLength = 24;
        }
      ];
      networking.defaultGateway = "192.168.3.1";
      networking.nameservers = ["192.168.3.22"];
      system.stateVersion = "24.11";
      nixpkgs.config.allowUnfree = true;
    };
  };
}
