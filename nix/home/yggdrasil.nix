{ pkgs, inputs, ... }: {
  imports = [ ./common-home.nix ./common-cli.nix ];

  home.stateVersion = "23.11";
  home.packages = with pkgs; [ garage ];

  xdg.configFile.".garage/config.toml".text = ''
    api_url = "http://192.168.3.34:3900"
  '';
}
