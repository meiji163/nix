{ pkgs, lib, config, ... }:
let
  # Platform detection
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # Import program configs
  zshConfig = import ./programs/zsh.nix { inherit pkgs lib config isDarwin isLinux; };
  gitConfig = import ./programs/git.nix { inherit pkgs lib; };
  emacsConfig = import ./programs/emacs.nix { inherit pkgs lib; };
in
{
  # Home-manager version
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # Import shared configurations
  imports = [
    ./programs/fzf.nix
    ./programs/direnv.nix
  ];

  # Common packages for all platforms
  home.packages = with pkgs; [
    # CLI tools
    coreutils
    curl
    fd
    fzf
    bat
    jq
    yq
    htop
    tree
    ripgrep
    ripgrep-all
    gnupg
    
    # Development
    nodejs_23
    gh
  ] 
  # Platform-specific packages
  ++ (if isDarwin then [
    # macOS-specific packages
  ] else [
    # Linux-specific packages
  ]);

  # Use configs imported above
  programs.zsh = zshConfig;
  programs.git = gitConfig;
  programs.emacs = emacsConfig;

  # Common shell aliases
  home.shellAliases = {
    ls = "ls --color";
    ll = "ls -l --color";
  } // (if isDarwin then {
    # macOS-specific aliases
    switch = "darwin-rebuild switch --flake ~/nix";
    emg = "emacsclient -c -n -a 'emacs'";
  } else {
    # Linux-specific aliases
    switch = "sudo nixos-rebuild switch --flake ~/nix";
  });

  home.sessionVariables = { 
    EDITOR = "vim"; 
  };

  # Dotfiles
  home.file = {
    ".vimrc".source = ./files/vimrc;
    ".tmux.conf".source = ./files/tmuxrc;
    ".alacritty.toml".source = ./files/alacritty.toml;
    ".zathurarc".source = ./files/zathurarc;
  };
}
