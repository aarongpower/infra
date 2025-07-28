{ config, pkgs, ... }:

let
  kubeMasterIP = "192.168.3.20";
  kubeMasterHostname = "kubernetes.default.svc.cluster.local";
  kubeMasterAPIServerPort = 6443;
in
{
  boot.kernelModules = [ "br_netfilter" "overlay" "ceph" ];
  
  # canonically required, but commented out as it is already defined elsewhere and is expected to be unique
  # boot.kernel.sysctl = {
    # "net.ipv4.ip_forward" = 1;
    # "net.bridge.bridge-nf-call-iptables" = 1;
    # "net.bridge.bridge-nf-call-ip6tables" = 1;
  # };

  virtualisation.podman.enable = true;

  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    flannel.enable = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    kubelet.extraOpts = "--fail-swap-on=false";
  };

  environment.systemPackages = with pkgs; [
    kubectl
    helm
    zfs
    ceph-client
    kompose
    kubernetes
  ];

  networking.firewall.allowedTCPPorts = [ 
    6443 # K8s API server
    6789 6800 74800 # Ceph ports
  ];

  # create a group to give permissions to users to manage k8s
  users.groups.kubernetes = {
    members = [ "aaronp" ];
  };

  # give members of kubernetes group the ability to access the cluster admin key so they can administrate
  # using am activation script because tmpfiles detects an "unsafe permission transition" and refuses to make the change
  system.activationScripts.setFilePerms = ''
    chown root:kubernetes /var/lib/kubernetes/secrets/cluster-admin-key.pem
    chmod 0640 /var/lib/kubernetes/secrets/cluster-admin-key.pem
  '';
}
