{ config, pkgs, ... }:

{
  # Latest kernel on every host.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking (per-host hostname is set in hosts/<name>/default.nix).
  networking.networkmanager.enable = true;

  # Locale & time
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # Shell
  programs.fish.enable = true;

  # User
  users.users.snacj = {
    isNormalUser = true;
    description = "Snacj";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.fish;
  };

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
    nerd-fonts.terminess-ttf
    nerd-fonts.departure-mono
    nerd-fonts.proggy-clean-tt
    nerd-fonts.hack
  ];

  # Shared across all current hosts; bump per-host if a machine is
  # installed against a newer release.
  system.stateVersion = "26.05";
}
