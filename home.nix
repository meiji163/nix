{ pkgs, ... }: {
  # this is internal compatibility configuration
  # for home-manager, don't change this!
  home.stateVersion = "24.11";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # utils
    curl
    gawk
    fd
    fzf
    bat
    jq
    yq
    htop
    ripgrep
    ripgrep-all
    zstd
    gnupg
    ispell

    # backup
    restic

    # font
    source-code-pro

    # dev
    babashka
    docker
    gh
    go
    gopls
    gotools
    rbenv
    kustomize

    # mullvad

    # shell
    zsh
    oh-my-zsh
    nnn
  ];

  home.shell.enableZshIntegration = true;
  home.shellAliases = {
    switch = "darwin-rebuild switch --flake ~/nix";
    emg = "emacsclient -c -n -a 'emacs'";
  };

  programs.zsh = {
    enable = true;
    history = {
      size = 1000000000;
      path = "$HOME/.cache/.zsh_history";
      findNoDups = true;
      extended = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    historySubstringSearch = { enable = true; };

    initExtra = ''
      # enable cd on ^G for nnn
      nnn() {
        declare -x +g NNN_TMPFILE=$(mktemp --tmpdir $0.XXXX)
        trap "rm -f $NNN_TMPFILE" EXIT
        =nnn $@
        [ -s $NNN_TMPFILE ] && source $NNN_TMPFILE
      }
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        {
          name = "mafredri/zsh-async";
          tags = [ "from:github" ];
        }
        {
          name = "sindresorhus/pure";
          tags = [ "use:pure.zsh" "from:github" "as:theme" ];
        }
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--bind 'alt-c:clear-query'"
      "--bind 'alt-u:first,alt-d:last'"
      "--bind 'alt-r:refresh-preview'"
      "--bind 'ctrl-w:preview-half-page-up,ctrl-s:preview-half-page-down'"
    ];
  };

  programs.git = {
    enable = true;
    userName = "meiji163";
    userEmail = "meiji163@github.com";
  };

  home.sessionVariables = { EDITOR = "vim"; };
  home.file = {
    ".vimrc".source = ./vimrc;
    ".tmux.conf".source = ./tmuxrc;
    ".alacritty.toml".source = ./alacritty.toml;
    ".zathurarc".source = ./zathurarc;
  };
}
