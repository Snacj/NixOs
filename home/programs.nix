{ config, pkgs, ... }:

{
  # Ghostty
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = IBM 5153 CGA (Black)
    confirm-close-surface = false
  '';

  # Tmux
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = builtins.readFile ./.config/tmux.conf;
  };

  # Git
  programs.git = {
    enable = true;
    settings = {
      user.name = "Snacj";
      user.email = "0xSnacj@proton.me";
      init.defaultBranch = "main";
    };
  };

  # SSH
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # Mako (notifications)
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      background-color = "#282828";
      text-color = "#ebdbb2";
      border-color = "#458588";
      border-radius = 4;
      padding = "10";
      default-timeout = 5000;
    };
  };
}
