{ lib, stdenv, fetchurl, libusb1, webkitgtk, gtk3 }:

let
  version = "1.1.1";
in
{
  pname = "keymapp";
  version = version;
  meta.description = "Firmware flashing and layout visualization tool for ZSA Technology Labs' keyboards";
  meta.license = lib.licenses.unfree;
  meta.mainprogram = "keymapp";
  
  src = fetchurl {
    url = "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-${version}.tar.gz";
    sha256 = "sha256-1rb0gri84wkhxrn01dlwm71dk8r35bkd05l39vqi131hzqbqnq06";
  };

  buildInputs = [ libusb1 webkitgtk gtk3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin
  '';
}
