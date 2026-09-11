{ config, pkgs, ... }:

{
  # kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking (hostname is set per host)
  networking.networkmanager.enable = true;

  # locale & time
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

  # shell
  programs.fish.enable = true;

  # user
  users.users.snacj = {
    isNormalUser = true;
    description = "Snacj";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    shell = pkgs.fish;
  };

  # nix
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # the hyprland input does not follow nixpkgs, so it is not in cache.nixos.org
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIITfGmveHsOO8NCF3q+j4="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  # dedupe on a timer instead of during every build
  nix.optimise.automatic = true;

  # system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  # jetbrainsmono for ghostty, bigblueterm for hyprlock and quickshell
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
  ];
}
