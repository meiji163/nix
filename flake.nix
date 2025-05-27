{
  description = "Cross-platform Nix configuration";

  inputs = {
    # Shared inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin-specific inputs
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";

    # NixOS-specific inputs
    # Add any NixOS-specific inputs here if needed
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nix-homebrew, mac-app-util, ... }:
    let
      # System types to support
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      
      # Helper function to generate an attribute set for each supported system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Import home configuration
      homeConfig = import ./home;
    in
    {
      # Darwin configurations
      darwinConfigurations."Meijkes-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/macbook
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "meiji163";
              autoMigrate = true;
            };
          }
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              users.meiji163 = homeConfig;
              sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            };
          }
        ];
      };

      # Home configurations for use with standalone home-manager
      homeConfigurations = {
        "meiji163@ubuntu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home/default.nix
            {
              home = {
                username = "meiji163";
                homeDirectory = "/home/meiji163";
                stateVersion = "24.11";
              };
            }
          ];
        };
      };
    };
}
