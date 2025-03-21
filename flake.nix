{
  description = "nix-darwin system flake";

  inputs = {
    # brew version issue: https://github.com/LnL7/nix-darwin/issues/1391
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.url =
      "git+https://github.com/zhaofengli/nix-homebrew?ref=refs/pull/71/merge";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nixpkgs, mac-app-util, nix-darwin, nix-homebrew
    , home-manager, ... }:
    let
      configuration = { pkgs, config, ... }: {

        nixpkgs.config.allowUnfree = true;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          nixfmt-classic
          neofetch
          vim
          tmux
          mkalias
          zathura
          alacritty
          brave
          keepassxc
        ];

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
                {
                  app =
                    "/Users/meiji163/homebrew/Cellar/emacs-plus@29/29.4/Emacs.app";
                }
              ];
            };
          };

          keyboard = {
            enableKeyMapping = true;
            remapCapsLockToControl = true;
          };

          # Set Git commit hash for darwin-version.
          configurationRevision = self.rev or self.dirtyRev or null;

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
      };
      homeconfig = import ./home.nix;
    in {
      darwinConfigurations."Meijkes-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "meiji163";
              autoMigrate = true;
            };
          }
          # mac-app-util creates wrappers for apps installed by nix
          # so they're indexed by spotlight
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          ({ pkgs, config, inputs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.meiji163 = homeconfig;
            home-manager.sharedModules =
              [ mac-app-util.homeManagerModules.default ];
          })

        ];
      };
    };
}
