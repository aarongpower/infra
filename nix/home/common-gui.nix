{
  pkgs,
  inputs,
  fenix,
  ...
}:

{
  home.packages = with pkgs; lib.mkAfter [
    drawio
    discord
    # nerdfonts
    nerd-fonts.caskaydia-cove
    obsidian
    syncthing
  ];
}