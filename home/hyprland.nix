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
        modules-right = [ "pulseaudio" "network" "cpu" "memory" ]
          ++ lib.optional (hostName == "voyager") "battery"
          ++ [ "tray" ];

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

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "bat {capacity}%";
          format-charging = "bat {capacity}% chr";
          format-plugged = "bat {capacity}% plg";
          tooltip-format = "{timeTo}, {power}W";
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
      #battery,
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

      #battery.warning {
        color: #D8B64A;
      }

      #battery.critical {
        color: #9e6b6b;
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
}
