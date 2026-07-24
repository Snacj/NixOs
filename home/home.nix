{ config, pkgs, lib, hostName, ... }:

let
  # Common Packages each Host shares
  commonPackages = with pkgs; [
    # terminal
    ghostty
    fastfetch
    tmux

    # editor
    neovim

    # launcher
    wofi

    # browser
    firefox

    # apps
    keepassxc
    pavucontrol
    thunar

    # utilities
    cloc
    claude-code
    fd
    fzf
    htop
    ripgrep
    tree
    unzip
    zip

    # wayland tools
    wl-clipboard
    grim
    slurp
    swappy

    # hypr ecosystem
    hyprpaper
    hypridle
    hyprlock
    hyprpicker

    # media / brightness
    playerctl
    brightnessctl
    gimp

    # social
    discord
  ];

  # Host Specific Packages
  hostPackages = {
    oss = with pkgs; [
      prismlauncher
      bambu-studio
    ];
  };
in
{
  imports = [
    ./shell.nix
    ./hyprland.nix
    ./programs.nix
  ];

  home.username = "snacj";
  home.homeDirectory = "/home/snacj";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Packages: shared base + whatever this host opts into.
  home.packages = commonPackages ++ (hostPackages.${hostName} or [ ]);

  # Cursor
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
