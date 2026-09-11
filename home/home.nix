{ config, pkgs, lib, hostName, ... }:

let
  # shared by every host
  commonPackages = with pkgs; [
    # terminal
    ghostty
    fastfetch
    tmux

    # editor
    neovim
    # rust toolchain for blink.cmp fuzzy matcher
    rustc
    cargo
    gcc

    # language servers
    emmet-ls
    jdt-language-server
    lua-language-server
    tree-sitter
    typescript-language-server
    vscode-langservers-extracted # html, css
    zls

    # launcher
    wofi
    fuzzel

    # browser
    firefox

    # apps
    keepassxc
    pavucontrol
    kdePackages.dolphin

    # utilities
    bat
    btop
    claude-code
    cloc
    cloudflared
    fd
    fzf
    glow
    htop
    lazygit
    localsend
    nwg-displays
    ripgrep
    tree
    unzip
    usbutils
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
    vesktop
  ];

  # host specific
  hostPackages = {
    oss = with pkgs; [
      prismlauncher
      # bambu-studio
    ];
  };
in
{
  imports = [
    ./shell.nix
    ./hyprland.nix
    ./quickshell.nix
    ./programs.nix
  ];

  home.username = "snacj";
  home.homeDirectory = "/home/snacj";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # shared base + host opt-ins
  home.packages = commonPackages ++ (hostPackages.${hostName} or [ ]);

  # cursor
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # gpg
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 600;
    maxCacheTtl = 7200;
  };
}
