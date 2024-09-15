{ pkgs, lib, config, agenix, ... }:

{
  imports = [
    agenix.homeManagerModules.default
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/id_ed25519"
  ];

  age.secrets.openai_api_key.file = ./secrets/openai_api_key.age;

  home.sessionVariables = {
    EDITOR = "hx";
    OPENAI_API_KEY = ''$(${pkgs.coreutils}/bin/cat ${config.age.secrets.openai_api_key.path})'';
  };

  # Helix configuration
  xdg.configFile."helix/config.toml".source = ./config/helix/config.toml;
  xdg.configFile."helix/languages.toml".source = ./config/helix/languages.toml;

  # direnv configuration
  xdg.configFile."direnv/direnvrc".source = ./config/direnv/direnvrc;

  # Default to nushell
  home.sessionVariables.SHELL = "${pkgs.nushell}/bin/nu";

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
      $env.EDITOR = "hx";
      $env.OPENAI_API_KEY = (^bash -c "echo $(${pkgs.coreutils}/bin/cat ${config.age.secrets.openai_api_key.path})");
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
      symbol = "↕️ ";
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
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "eza -l";
      bs = "concierge";
      cat = "bat";
      dumpconf = "~/.nixcfg/dumpconf.sh";
      clipme = "wl-clip";
      lg = "libgen-cli";
      work = "moonlight stream -config /mnt/bigboy/vm/work/work.moonlight.cfg";
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
      plugins = [
        "git"
      ];
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
    settings = {
      shell = {
        program = "${pkgs.nushell}/bin/nu";
        args = [ "-c" "${pkgs.zellij}/bin/zellij attach rusty-rustacean" ];
      };
      font = {
        size = 10;
        # family = "CaskaydiaCove Nerd Font";
      };
    };
  };
}
