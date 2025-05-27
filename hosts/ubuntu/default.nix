{ config, pkgs, ... }:
{
  imports = [
    # Include hardware configuration
    # ./hardware-configuration.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader configuration (adjust as needed for your system)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "ubuntu-machine";
    networkmanager.enable = true;
  };

  # Set your time zone
  time.timeZone = "America/Los_Angeles"; # Adjust for your location

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  # System packages
  environment.systemPackages = with pkgs; [
    # Basic utilities
    vim
    wget
    curl
    rsycn
    git
    tmux
    zsh
    
    # GUI applications
    alacritty
    brave
    keepassxc
    syncthing
    zathura
  ];

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable X11
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # User account
  users.users.meiji163 = {
    isNormalUser = true;
    home = "/home/meiji163";
    description = "meiji163";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.zsh;
  };

  # Enable nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # State version
  system.stateVersion = "24.11";
}
