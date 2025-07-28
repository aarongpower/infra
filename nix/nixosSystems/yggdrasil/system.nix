{globals}: rec {
  systemName = builtins.baseNameOf (toString ./.);
  useProxmox = true;
  useContainers = true;
  user = "aaronp";
  system = "x86_64-linux";

  ## after here everything is derived from the above values
  systemDir = "${globals.flakeRoot}/nixosSystems/${systemName}";
  containers = "${systemDir}/containers";
}
