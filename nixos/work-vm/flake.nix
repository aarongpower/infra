{
  description = "A Nix flake that is used to start my Office Windows VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    packages.x86_64-linux.work-vm = pkgs.stdenv.mkDerivation {
      name = "work-vm";
      src = self;

      # Use 'pkgs' from the function argument 'nixpkgs'
      buildInputs = [ pkgs.qemu pkgs.OVMF pkgs.swtpm ];

      installPhase = ''
        mkdir -p $out/bin $out/share/ovmf
        cp $src/start-windows-vm.sh $out/bin/workvm
        chmod +x $out/bin/workvm

        # Copy the OVMF_VARS.fd file
        cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd $out/share/ovmf/

        # Substitute paths in the script
        substituteInPlace $out/bin/workvm \
          --replace "__qemu-system-x86_64__" "${pkgs.qemu}/bin/qemu-system-x86_64" \
          --replace "__OVMF_CODE.fd__" "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd" \
          --replace "__OVMF_VARS.fd__" "$out/share/ovmf/OVMF_VARS.fd" \
          --replace "__swtpm__" "${pkgs.swtpm}/bin/swtpm" \
      '';
    };
  };
}
