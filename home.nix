{ pkgs, lib, config, ... }:
let
  emacs-overlay = import (fetchTarball {
    url =
      "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    sha256 = "1jppksrfvbk5ypiqdz4cddxdl8z6zyzdb2srq8fcffr327ld5jj2";
  });
  my-emacs = pkgs.emacs30.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
  };
  my-emacs-with-packages = (pkgs.emacsPackagesFor my-emacs).emacsWithPackages
    (epkgs:
      with epkgs; [
        pkgs.mu
        vterm
        multi-vterm
        pdf-tools
        treesit-grammars.with-all-grammars
      ]);
in {
  # this is internal compatibility configuration
  # for home-manager, don't change this!
  home.stateVersion = "24.11";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  programs.opam = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    ## utils
    binutils
    coreutils
    curl
    gawk
    fd
    fzf
    bat
    jq
    yq
    htop
    tree
    gnugrep
    ripgrep
    ripgrep-all
    zstd
    ispell
    gnupg
    inetutils

    ## backup
    restic
    rsync

    ## font
    emacs-all-the-icons-fonts
    source-code-pro

    ## dev
    babashka
    go
    gopls
    gotools
    golangci-lint
    delve
    lldb
    nodejs_23
    vscode

    # niv
    docker
    colima
    gh
    kustomize
    qemu

    ## shell
    zsh
    oh-my-zsh
    nnn
    shfmt

    ## database
    mysql84
    sqlite
    sysbench

    (aspellWithDicts (d: [ d.en d.sv ]))

    ## documents
    ghostscript
    tetex
    poppler
    mu
    pandoc
    wordnet
  ];

  home.shell.enableZshIntegration = true;
  home.shellAliases = {
    switch = "darwin-rebuild switch --flake ~/nix";
    emg = "emacsclient -c -n -a 'emacs'";
    ls = "ls --color";
    ll = "ls -l --color";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    zprof.enable = false;

    completionInit = ''
      if [[ -n $(print ~/.zcompdump(Nmh+24)) ]] {
        # Regenerate completions because the dump file hasn't been modified within the last 24 hours
        compinit
      } else {
        # Reuse the existing completions file
        compinit -C
      }
    '';

    history = {
      size = 1000000000;
      path = "$HOME/.cache/.zsh_history";
      append = true;
      extended = true;
      share = true;
    };

    historySubstringSearch = { enable = true; };

    initExtra = lib.strings.concatStringsSep "\n" [
      ''
        # enable cd on ^G for nnn
        nnn() {
          declare -x +g NNN_TMPFILE=$(mktemp --tmpdir $0.XXXX)
          trap "rm -f $NNN_TMPFILE" EXIT
          =nnn $@
          [ -s $NNN_TMPFILE ] && source $NNN_TMPFILE
        }
      ''
      ''
        # enable vi mode
        bindkey -v
      ''
      ''
        # doom binary
        export PATH="$PATH:$HOME/.config/emacs/bin"
      ''
    ];

    zplug = {
      enable = true;
      plugins = [
        # { name = "zsh-users/zsh-autosuggestions"; }
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

  # programs.rbenv = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   plugins = [{
  #     name = "ruby-build";
  #     # find sha256 of release:
  #     # nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url --unpack https://github.com/rbenv/ruby-build/archive/refs/tags/v20250318.tar.gz)
  #     src = pkgs.fetchFromGitHub {
  #       owner = "rbenv";
  #       repo = "ruby-build";
  #       rev = "v20250318";
  #       sha256 = "sha256-QrMkFM4ntzvO319kcIZeXUETNG3j27spNlze6S4jX/U=";
  #     };

  #   }];
  # };

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

  programs.emacs = {
    enable = true;
    package = my-emacs-with-packages;
  };

  # home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ]
  #   "${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${doomemacs}/ ${config.xdg.configHome}/emacs/";

  home.sessionVariables = { EDITOR = "vim"; };
  home.file = {
    ".vimrc".source = ./vimrc;
    ".tmux.conf".source = ./tmuxrc;
    ".alacritty.toml".source = ./alacritty.toml;
    ".zathurarc".source = ./zathurarc;
  };
}
