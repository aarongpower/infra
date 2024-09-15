{ pkgs, windows-vm, ... }:

{
  users.groups.bigboyntfs = {
    gid = 1000;
  };
  users.groups.media = {
    gid = 1001;
  };
  users.groups.vfio = {}; # vfio group
  users.groups.netdev = {};
  users.groups.aaronp = {};

  users.users.aaronp = {
    isNormalUser = true;
    shell = "${pkgs.nushell}/bin/nu";
    description = "Aaron Power";
    extraGroups = [ "networkmanager" "wheel" "bigboyntfs" "input" "libvirtd" "qemu-libvirtd" "vfio" "plugdev" "libvirt" "kvm" "netdev" "aaronp"];
    packages = with pkgs; [

    ];
    openssh = {
      authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdDtpJfoDrvCg8OFE57JihGkC37Fujk29fCWiuuj3bwUgvu5Bx+1ln7V0xg554u1mya6lz7uAZtzBNH7D0BUQtZtAr+sc9L7pyMJGhjx/QyRVq452a+P/A7jDA2E+UDA/8acr6DAkBz93/Ia5KoP7Y9YbI7awutZLbgwOeHRqBBV7dy7CWDoCMiFRb8rSqGN/NXl1c6fDz6cnAK3ci9RQEOL9QHcuwm0hhj9Brs/+uxZM+Rqe7kIm6RkSUNfmz0TiLyxUPa/tQLogmgjCKoCZQ8hC79g5d5u5cO4mmoYYh/ig8IFYpyxul2MAIDnzcuSVqarTSvEAEfJ+ZtJMT3PasryfSK5j00ewq5BVRy/7gIDVMF+Lyzvn6S9t5vnspGnfSXsMRqeBuIQiGtFzsMvqArJ+nWK8T5Iw18wzCup33LEW3jA8dtXadjK/0JwKdWY6rC+St3BRYpsp/MIi0V/B3F8OXpoQT3+ZegpveDVL326C7JjUaeRLoBZwBMsGJjxU= aaronpower@MacBook-Pro.lan"
      ];
    };
  };
}
