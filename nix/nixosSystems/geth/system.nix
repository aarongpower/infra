{globals}: rec {
  systemName = builtins.baseNameOf (toString ./.);
  useProxmox = false;
  useContainers = false;
  useCopyParty = false;
  user = "aaronp";
  system = "x86_64-linux";

  ## after here everything is derived from the above values
  systemDir = "${globals.flakeRoot}/nixosSystems/${systemName}";
  containers = "${systemDir}/containers";
}
