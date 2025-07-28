{
  pkgs,
  inputs,
  ...
}:
let 
  baseShell = inputs.tf-ncl.lib.${pkgs.system}.mkDevShell {
    providers = p: {
      inherit (p) azurerm null;
    };
    extraNickelInput = "";
    packages = with pkgs; [
      python312
      uv
      terraform
      ansible
      go
      nixfmt-rfc-style
      alejandra
      jq
      nickel
      nls
      inputs.tf-ncl.packages.${pkgs.system}.default
    ];
  };
in
  baseShell.overrideAttrs (oldAttrs: {
    shellHook = ''  
      export UV_VENV_DIR=$PWD/.venv
      if [ ! -d .venv ]; then
        uv venv
      fi
      uv sync
      export PATH=$UV_VENV_DIR/bin:$PATH
    '';
  })
