{
  pkgs,
  inputs,
  config,
  globals,
  ...
}: let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in {
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];

  # sops config
  sops = {
    age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    defaultSopsFile = "${globals.flakeRoot}/secrets/admin-aaronp.yaml";
    secrets.openai_api_key = {};
  };

  # age.identityPaths = [
  #   "${config.home.homeDirectory}/.ssh/id_ed25519"
  # ];

  # age.secrets.openai_api_key.file = ./secrets/openai_api_key.age;

  home.sessionVariables = {
    EDITOR = "hx";
    # OPENAI_API_KEY = ''$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.openai_api_key.path})'';
  };

  # Helix configuration
  xdg.configFile."helix/config.toml".source = ./config/helix/config.toml;
  xdg.configFile."helix/languages.toml".source = ./config/helix/languages.toml;

  # direnv configuration
  xdg.configFile."direnv/direnvrc".source = ./config/direnv/direnvrc;

  # Default to nushell
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      "yggdrasil" = {
        hostname = "192.168.3.20";
        user = "aaronp";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
    # knownHosts = {
    #  "yggdrasil-ed25519" = {
    #     hostNames = [ "192.168.3.20" "yggdrasil.rumahindo.lan" ];
    #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPGfcCOn0yr2dLWpEInCsW7aMrT3M1XxUcJmZObtWwT";
    #   };
    #   "yggdrasil-rsa" = {
    #     hostNames = [ "192.168.3.20" "yggdrasil.rumahindo.lan" ];
    #     publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3e6cg9jlNkStLqIZltNdcEtM5fLnbBzvcHRIrVbueQo5XVEYjLjfY0vLqvsMokGk1K539tBE7LzwGmrh8PL/ZR83Bj2Kgz+uUauBnUufA3C0uJFyOjcsx3vhbry12srOEupnJPeevlSrLBUNpLElHjhPsEknjljM7ATxGmy/teYziPtkdO5DUPgTM50QA4q7LtEV3jkmUpTJB2IuUa8hkl9++DYq42QE/8hcizLVkgLehaMrhmDz7U9za0qQEy3AyOiKSUSuskQ1iVGt7uQH4eST6X8LsfrRVnHSRgJTekJSoIq3ONqqFdq5I2GArjMQ+EJB1g0whNcmNKDYdieV0V+A3LJluVJ1R9SdIhDHh2ZWQjkgj4Uo7o8N1bFNlmJgerMb5vlNg8bTXBDp1H/jRx8Y6TJNIIW/P6xdk8+jEK05mCn1hpup6q17oayTCEHj6w76njA78bLU/hQ6ZeI2nCrr//MR8ZWFQyF7HGqHI1pPAkl+vyzwE6HdBrh8/h9foU42W2hOAQJhOiKlU66QPj7Boapumawkxlh+iHsO+M8C6bSBoWWMjFapNYWm5/1q+2tbrpgD8uDEPn5X9tXcnt3g4ZOJbPiw3u7eHNz7P41VTxXj0tsSx7ehHX/PHjsgZCh4PEqbmwbIPjnJk7HD6uYt6YfI03+lKbtr5MWso7Q==";
    #   };
    #   "yggdrasil-cloudflare" = {
    #     hostNames = [ "192.168.3.20" "yggdrasil.rumahindo.lan" ];
    #     publicKey= "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrAGLsDAdnZ9tQ2RHlwMxhLQJIUeslHpyN2w4TiKfvv";
    #   };
    # };
    # extraConfig = ''
    #   Host github.com
    #     HostName github.com
    #     User git
    #     identityFile ~/.ssh/id_ed25519
    #     IdentitiesOnly yes
    # '';
  };

  programs.nushell = {
    enable = true;
    configFile.source = ./config/nushell/config.nu;
    envFile.source = ./config/nushell/env.nu;
    shellAliases = {
      bs = "concierge";
      ll = "ls -al";
      cat = "bat";
      cd = "z";
      # z = "zoxide";
    };
    extraEnv = ''
      $env.EDITOR = "hx"
      $env.OPENAI_API_KEY = (
        open ${config.sops.secrets.openai_api_key.path}
        | str trim
      )
    '';
  };
  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

  programs.fish.enable = true;
  programs.zoxide.enable = true;

  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = true;
    command_timeout = 2000;
    format = "$all";
    shlvl = {
      disabled = false;
      symbol = "🞊 ";
      style = "bright-red bold";
    };
    shell = {
      disabled = false;
      format = "$indicator";
      fish_indicator = "[fish](bright-white)";
      bash_indicator = "[bash](bright-white)";
      zsh_indicator = "[zsh](bright-white)";
      nu_indicator = "[nu](bright-white)";
    };
    character = {
      success_symbol = "[ >](green bold)";
      error_symbol = "[ ✖️>](red bold)";
    };
    username = {
      style_user = "bright-white bold";
      style_root = "bright-red bold";
    };
    right_format = "$time";
    time = {
      disabled = false;
      format = "[ $time ](#474747) ";
      time_format = "%Y-%m-%dT%H:%M:%S";
    };
  };

  programs.git = {
    enable = true;
    userName = "Aaron Power";
    userEmail = "aarongpower@gmail.com";
    extraConfig = {init = {defaultBranch = "main";};};
  };

  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "eza -l";
      bs = "concierge";
      cat = "bat";
      # dumpconf = "~/.nixcfg/dumpconf.sh";
      # clipme = "wl-clip";
      lg = "libgen-cli";
      cd = "z";
      # work = "moonlight stream -config /mnt/bigboy/vm/work/work.moonlight.cfg";
    };
    # autoSuggestions.enable = true;
    syntaxHighlighting.enable = true;
    # The documentation LIES TO YOU!
    # At the NixOS documentation here: https://nixos.wiki/wiki/Zsh
    # Indicates that it should be "ohMyZsh"
    # But it deceives you! Do not fall for these lies!
    # It should be "oh-my-zsh"
    # How do I know? Because I was at my wits end and decided to change it to match the package name used to install oh-my-zsh
    # https://search.nixos.org/packages?channel=23.11&show=oh-my-zsh&from=0&size=50&sort=relevance&type=packages&query=oh-my-zsh
    # And now it works. So there you go.
    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zellij.enable = true;

  programs.alacritty = {
    enable = true;
    package = unstable.alacritty;
    settings = {
      terminal.shell = {
        program = "${pkgs.zsh}/bin/fish";
        args = ["-c" "${pkgs.zellij}/bin/zellij"];
      };
      font = {
        size = 10;
        # family = "CaskaydiaCove Nerd Font";
      };
    };
  };
}
