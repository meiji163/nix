{ pkgs, config, ... }: 
{
  nixpkgs.config.allowUnfree = true;
  
  # System packages for macOS
  environment.systemPackages = with pkgs; [
    nixfmt-classic
    cowsay
    neofetch
    vim
    zsh
    tmux
    mkalias
    syncthing
    zathura
    alacritty
    brave
    keepassxc
  ];
  
  environment.pathsToLink = [ "/share/zsh" ];

  ids.gids.nixbld = 30000;
  
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  
  users.users.meiji163 = {
    name = "meiji163";
    home = "/Users/meiji163";
  };

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        show-recents = false;
        tilesize = 75;
        orientation = "bottom";
        persistent-apps = [
          { app = "/System/Applications/Launchpad.app"; }
          { app = "/Applications/Slack.app"; }
          { app = "/Applications/Google Chrome.app"; }
          { app = "${pkgs.alacritty}/Applications/Alacritty.App"; }
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXEnableExtensionChangeWarning = false;
      };
      # tab between form controls and F-row that behaves as F1-F12
      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        "com.apple.keyboard.fnState" = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # Set Git commit hash for darwin-version.
    configurationRevision = null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  homebrew = {
    enable = true;
    # onActivation.cleanup = "uninstall";
    taps = [ ];
    brews = [ "mas" "wireshark" ];
    casks = [
      "maccy"
      "hammerspoon"
      "viscosity"
      "docker"
      "xquartz"
      "miniforge"
      "vlc"
    ];
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "wireguard" = 1451685025;
      "localsend" = 1661733229;
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;
}
