{ config, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/nixos-config";
in
{
  # ghostty; other themes: IBM 5153 CGA (Black)
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = Gruvbox Material
    confirm-close-surface = false
  '';

  # nvim, out-of-store so a keymap change needs no rebuild
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/home/.config/nvim";

  # tmux
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = builtins.readFile ./.config/tmux.conf;
  };

  # git
  programs.git = {
    enable = true;
    settings = {
      user.name = "Snacj";
      user.email = "0xSnacj@proton.me";
      init.defaultBranch = "main";
    };
  };

  # ssh; block order matters with enableDefaultConfig off, so keep them together
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
      "homeserver" = {
        Hostname = "ssh.snacj.com";
        User = "system";
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };
    };
  };

  # mako, off because quickshell owns org.freedesktop.Notifications
  services.mako = {
    enable = false;
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
