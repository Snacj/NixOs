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
    # rust toolchain for blink.cmp's native fuzzy matcher build
    rustc
    cargo
    gcc

    # language servers (neovim)
    lua-language-server
    zls
    typescript-language-server
    vscode-langservers-extracted # html, css
    emmet-ls
    jdt-language-server # jdtls

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
    htop
    localsend
    ripgrep
    tree
    unzip
    usbutils
    zip
    nwg-displays

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
  home.pointerCursor.enable = true;
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # gpg
    programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 600;
    maxCacheTtl = 7200;
  };

  # ssh
  programs.ssh.extraConfig = ''
    Host homeserver
      HostName ssh.snacj.com
      User system
      ProxyCommand cloudflared access ssh --hostname %h
  '';
}
