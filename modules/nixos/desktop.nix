{ pkgs, inputs, ... }:

{
  # hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.x86_64-linux.hyprland;
    portalPackage = inputs.hyprland.packages.x86_64-linux.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    # pin the backend instead of letting the portal guess
    config.common.default = [ "hyprland" "gtk" ];
  };

  # removable media, otherwise dolphin cannot mount
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
      user = "greeter";
    };
  };
}
