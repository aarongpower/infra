# Install packages as AppImages
{ pkgs, lib, globals, ... }:

let
  ciderAppImage = "${globals.flakeRoot}/vendor/cider-3.1.2-x86_64.AppImage";
in
{
  environment.systemPackages = lib.mkAfter [
    (pkgs.appimageTools.wrapType2 {
      pname = "cider";
      version = "3.1.2";
      src = ciderAppImage;   # <- local path, no sha256 needed
    })
  ];
}
