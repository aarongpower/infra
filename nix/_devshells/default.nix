{
  pkgs,
  inputs,
  globals,
  ...
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
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
  ];
  shellHook = ''
    export UV_VENV_DIR=$PWD/.venv

    if [ ! -d .venv ]; then
      uv venv
    fi

    uv sync
    export PATH=$UV_VENV_DIR/bin:$PATH
  '';
}
