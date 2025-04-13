{ pkgs, lib, config, isDarwin, isLinux, ... }:
{
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

  initExtra = lib.strings.concatStringsSep "\n" ([
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
  ] ++ (if isDarwin then [
    # macOS-specific zsh config
    ''
      # macOS-specific settings
      export PATH="/opt/homebrew/bin:$PATH"
    ''
  ] else [
    # Linux-specific zsh config
    ''
      # Linux-specific settings
    ''
  ]));

  zplug = {
    enable = true;
    plugins = [
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
}
