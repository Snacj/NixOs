{ config, pkgs, ... }:

{
  home.username = "snacj";
  home.homeDirectory = "/home/snacj";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Packages
  home.packages = with pkgs; [
    # terminal
    ghostty
    tmux

    # editor
    neovim

    # launcher
    wofi

    # browser
    firefox

    # apps
    keepassxc
    pavucontrol
    thunar

    # utilities
    ripgrep
    fd
    fzf
    unzip
    zip
    tree

    # wayland tools
    wl-clipboard
    grim
    slurp
    swappy

    # hypr ecosystem
    hyprpaper
    hypridle
    hyprlock
    hyprpicker

    # media / brightness
    playerctl
    brightnessctl

    # social
    discord

    # notification
    mako
  ];

  # Ghostty
  xdg.configFile."ghostty/config".text = ''
    font-family = Hack
    theme = Gruvbox Dark
    confirm-close-surface = false
  '';

  # Dev Shell
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Tmux
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = builtins.readFile ./.config/tmux.conf;
  };

  # Bash
  programs.bash = {
    enable = false;
    shellAliases = {
      ll  = "ls -la --color=auto";
      ls  = "ls --color=auto";
      gs  = "git status";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
  };

  # Fish
  programs.fish = {
    enable = true;

    shellAliases = {
      ls      = "ls --color=auto";
      grep    = "grep --color=auto";
      ll      = "ls -la --color=auto";
      v       = "nvim";
      notes   = "nvim ~/Notes";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      gs      = "git status";
    };

    functions = {
      fish_greeting = "";

      fish_prompt = ''
        set_color brblack
        printf "[%s] " (date "+%H:%M")

        set_color cyan
        printf "%s" $USER

        set_color normal
        printf ":"

        set_color yellow
        printf "%s" (basename (pwd))

        set_color normal

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set branch (git branch --show-current 2>/dev/null)
            if test -n "$branch"
                set_color green
                printf " (%s)" $branch
            end
        end

        # Nix dev shell indicator
        if set -q DIRENV_DIR
            set_color magenta
            printf " [develop]"
        end

        set_color red
        printf " | "
      '';

      copyraw = {
        description = "Copy raw file content to clipboard using wl-copy";
        body = ''
          if test (count $argv) -gt 0
            cat $argv | wl-copy
          else
            cat | wl-copy
          end
        '';
      };

      f = {
        description = "Fuzzy find files and open in nvim";
        body = "fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -o nvim $argv";
      };

      fp = {
        description = "Fuzzy find with preview and open in nvim";
        body = ''fzf --preview="cat {}" | xargs -r nvim $argv'';
      };
    };

    interactiveShellInit = ''
      zoxide init fish | source
    '';

    shellInit = ''
      fish_add_path ~/.local/bin
    '';
  };

  # Zoxide (provides the z command)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
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

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };
  xdg.configFile."hypr/hyprland.lua".source = ./.config/hyprland.lua;
  xdg.configFile."hypr/hypridle.conf".source = ./.config/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./.config/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ./.config/hyprpaper.conf;

  # Waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        position = "bottom";
        height = 24;
        spacing = 0;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];

        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          format = "{name}";
          on-click = "hyprctl dispatch workspace={name}";
          persistent-workspaces."*" = [ 1 2 3 4 5 6 7 8 9 ];
        };

        tray.spacing = 8;

        clock = {
          format = "{:%A | %H:%M | %d %B}";
          format-alt = "{:%H:%M}";
          on-click-right = "";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months   = "<span color='#6a6a6a'><b>{}</b></span>";
              days     = "<span color='#6b9e78'><b>{}</b></span>";
              weeks    = "<span color='#add8e6'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today    = "<span color='#9e6b6b'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        cpu = {
          format = "cpu {usage}%";
          tooltip = false;
          interval = 2;
        };

        memory = {
          format = "mem {used:0.1f}/{total:0.1f} GB";
          interval = 2;
        };

        network = {
          format-wifi = "{essid}";
          family = "ipv4";
          format-ethernet = "eth";
          format-linked = "{ifname}";
          format-disconnected = "offline";
          format-alt = "{ifname} {ipaddr}";
          tooltip-format-wifi = "{essid}\n{signalStrength}%";
        };

        pulseaudio = {
          format = "vol {volume}%";
          format-bluetooth = "bt {volume}%";
          format-muted = "muted";
          format-source = "";
          format-source-muted = "";
          on-click = "pavucontrol";
          scroll-step = 5;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "BigBlueTerm437 Nerd Font Mono", "DepartureMono Nerd Font Mono", "Terminus (TTF)", "Terminus", "ProggyCleanTT", monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background-color: #2b2b2b;
        color: #e0e0e0;
        border-top: 1px solid #3a3a3a;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      tooltip {
        background: #1f1f1f;
        border: 1px solid #3a3a3a;
        color: #e0e0e0;
      }

      tooltip label {
        color: #e0e0e0;
      }

      #workspaces {
        margin: 0 4px 0 6px;
        padding: 0;
        background: transparent;
      }

      #workspaces button {
        padding: 0 3px;
        margin: 0;
        color: #6a6a6a;
        background: transparent;
        border-radius: 0;
        border-bottom: 2px solid transparent;
        font-weight: normal;
        transition: color 0.15s ease;
      }

      #workspaces button:hover {
        background: transparent;
        color: #b0b0b0;
        box-shadow: none;
        text-shadow: none;
      }

      #workspaces button:not(.empty) {
        color: #D8B64A;
      }

      #workspaces button.active,
      #workspaces button.focused {
        color: #D8B64A;
        border-bottom: 2px solid #D8B64A;
      }

      #workspaces button.urgent {
        color: #D8B64A;
        background: transparent;
      }

      #window {
        margin: 0 8px;
        padding: 0;
        color: #8a8a8a;
        font-style: normal;
      }

      #clock {
        padding: 0 10px;
        color: #D8B64A;
        background: transparent;
      }

      #pulseaudio,
      #network,
      #cpu,
      #memory,
      #tray {
        padding: 0 8px;
        margin: 0;
        background: transparent;
        color: #987654;
        font-weight: normal;
      }

      #pulseaudio.muted {
        color: #6a6a6a;
      }

      #network.disconnected {
        color: #6a6a6a;
      }

      #cpu,
      #memory {
        color: #987654;
      }

      #tray {
        margin-right: 6px;
      }

      #tray > .needs-attention {
        background: transparent;
        color: #987654;
        -gtk-icon-effect: highlight;
      }

      #pulseaudio:hover,
      #network:hover,
      #clock:hover {
        color: #D8B64A;
      }
    '';
  };

  # Cursor
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # Neovim
  home.sessionVariables = {
    EDITOR = "nvim";
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
