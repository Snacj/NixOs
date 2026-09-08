{ config, pkgs, lib, inputs, hostName, ... }:

{
  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.x86_64-linux.hyprland;
  };

  xdg.configFile."hypr/hyprland.lua".source = ./.config/hyprland.lua;
  xdg.configFile."hypr/hypridle.conf".source = ./.config/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./.config/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./.config/hyprpaper.conf;
}
