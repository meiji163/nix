{
  config,
  pkgs,
  lib,
  ...
}:

let
  sabaki = pkgs.callPackage ./packages/sabaki.nix { };
  my-emacs = pkgs.callPackage ./packages/emacs.nix { };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "meiji163";
  home.homeDirectory = "/home/meiji163";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    localsend
    keepassxc

    ## weiqi
    sabaki
    cgoban

    ## utils
    binutils
    coreutils
    inetutils
    curl
    git
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
    nixfmt-rfc-style

    ## audio
    vlc
    audacity

    ## backup & sync
    restic
    rsync
    nextcloud-client
    syncthing

    ## font
    emacs-all-the-icons-fonts
    source-code-pro

    ## dev
    # babashka
    # go
    # gopls
    # gotools
    # golangci-lint
    # delve
    # lldb
    # nodejs_23
    # vscode

    # niv
    docker
    colima
    gh
    kustomize
    qemu

    ## shell
    # zsh
    alacritty
    oh-my-zsh
    tmux
    nnn
    shfmt

    (aspellWithDicts (d: [
      d.en
      d.sv
    ]))

    ## documents
    ghostscript
    tetex
    poppler
    mu
    pandoc
    wordnet
    zathura
    inkscape

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".tmux.conf".source = ./configs/tmuxrc;
    ".alacritty.toml".source = ./configs/alacritty.toml;
    ".zathurarc".source = ./configs/zathurarc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/meiji163/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  home.shell.enableZshIntegration = true;
  home.shellAliases = {
    switch = "home-manager switch";
    rebuild = "nixos-rebuild switch";
    ll = "ls -l --color";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userEmail = "me@meiji163.xyz";
    userName = "meiji163";
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimuim
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc browser
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };

  programs.emacs = {
    enable = true;
    package = my-emacs;
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

    historySubstringSearch = {
      enable = true;
    };

    initContent = lib.strings.concatStringsSep "\n" [
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
          tags = [
            "use:pure.zsh"
            "from:github"
            "as:theme"
          ];
        }
      ];
    };
  };
}
