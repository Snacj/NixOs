{ config, pkgs, lib, ... }:

let
  repo = "${config.home.homeDirectory}/nixos-config";
in
{
  # bar, osd and notification daemon; replaces waybar and mako
  home.packages = [ pkgs.quickshell ];

  # out-of-store so a widget tweak is qs reload instead of a rebuild
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/home/.config/quickshell";
}
