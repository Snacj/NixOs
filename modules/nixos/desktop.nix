{ pkgs, ... }:

{
  # Hyprland compositor
  programs.hyprland.enable = true;

  # Login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
      user = "greeter";
    };
  };
}
