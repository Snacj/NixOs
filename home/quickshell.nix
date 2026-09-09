{ config, pkgs, lib, ... }:

{
  # Quickshell: bar, on-screen display and notification daemon.
  #
  # Replaces waybar (old config in waybar.nix.bak) and mako (disabled in
  # programs.nix, since two daemons cannot both own
  # org.freedesktop.Notifications).
  #
  # Runtime dependencies, all already in home.nix: brightnessctl for the
  # brightness OSD, pavucontrol for the audio panel's escape hatch.
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell" = {
    source = ./.config/quickshell;
    recursive = true;
  };
}
