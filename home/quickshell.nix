{ config, pkgs, lib, ... }:

{
  # Quickshell bar (replaces waybar; the old config lives in waybar.nix.bak).
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell" = {
    source = ./.config/quickshell;
    recursive = true;
  };
}
