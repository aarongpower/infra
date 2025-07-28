{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./common-home.nix
  ];

  home.stateVersion = "23.11";
  home.packages = let
    commonCliPackages = import ./common-pkgs-cli.nix {inherit pkgs inputs;};
    localPackages = with pkgs; [
      garage
    ];
  in
    localPackages ++ commonCliPackages;

  xdg.configFile.".garage/config.toml".text = ''
    api_url = "http://192.168.3.34:3900"
  '';
}
