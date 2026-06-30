{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot 
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking 
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale & Time 
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

  # Hyprland 
  programs.hyprland.enable = true;

  # login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
      user = "greeter";
    };
  };

  # Sound (PipeWire) 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages 
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  # Fonts 
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.bigblue-terminal
    nerd-fonts.departure-mono
    nerd-fonts.proggy-clean-tt
    terminus_font_ttf
  ];

  # AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  system.stateVersion = "26.05";
}
