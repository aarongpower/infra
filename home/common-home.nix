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

  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = true;
    command_timeout = 2000;
    format = "$time\n$all";
    shlvl = {
      disabled = false;
      symbol = "↕️ ";
      style = "bright-red bold";
    };
    shell = {
      disabled = false;
      format = "$indicator";
      fish_indicator = "[FISH](bright-white) ";
      bash_indicator = "[BASH](bright-white) ";
      zsh_indicator = "";
    };
    username = {
      style_user = "bright-white bold";
      style_root = "bright-red bold";
    };
    time = {
      disabled = false;
      format = "🕙[ $time ](blue) ";
      time_format = "%Y-%m-%dT%H:%M:%S";
    };
  };

  programs.git = {
    enable = true;
    userName = "Aaron Power";
    userEmail = "aarongpower@gmail.com";
  };

  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "eza -l";
      buildsys = "source ~/.nixcfg/sync";
      bs = "buildsys";
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

  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${pkgs.zellij}/bin/zellij";
      };
      font = {
        size = 10;
        # family = "CaskaydiaCove Nerd Font";
      };
    };
  };
}
