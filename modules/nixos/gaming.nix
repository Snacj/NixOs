{ ... }:

{
  # Steam + gamescope session
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
}
