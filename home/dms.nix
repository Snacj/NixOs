{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.dank-material-shell.homeModules.dank-material-shell ];

  # DankMaterialShell (DMS): bar, OSDs, notification daemon, polkit agent and
  # control centre, all in one Quickshell-based shell.
  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # fix steam notifications above bar
  systemd.user.sessionVariables.DMS_DANKBAR_LAYER = "bottom";

  # fix wayscriber's icon
  xdg.dataFile."icons/hicolor/scalable/apps/wayscriber.svg".source =
    ./icons/wayscriber.svg;
}
