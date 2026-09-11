{ config, pkgs, lib, inputs, hostName, ... }:

let
  repo = "${config.home.homeDirectory}/nixos-config";
in
{
  # hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.x86_64-linux.hyprland;
  };

  # polkit agent, otherwise gui privilege prompts fail silently
  services.hyprpolkitagent.enable = true;

  xdg.configFile."hypr/hyprland.lua".source = ./.config/hyprland.lua;
  xdg.configFile."hypr/hypridle.conf".source = ./.config/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./.config/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./.config/hyprpaper.conf;

  # per-host layout for require("monitors"); out-of-store so nwg-displays can write it
  xdg.configFile."hypr/monitors.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/home/hosts/${hostName}/monitors.lua";
}
