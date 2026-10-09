{ config, ... }:

let
  c = import ./colors.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        output = config.hypr.primaryMonitor;
        layer = "top";
        position = "top";
        height = 38;
        spacing = 0;

        modules-left = [
          "custom/nixos"
          "hyprland/workspaces"
          "network"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "mpris"
          "tray"
          "wireplumber"
          "battery"
          "custom/dunst"
          "clock"
        ];

        "custom/nixos" = {
          format = "";
          tooltip = false;
          on-click = "rofi -show drun";
        };

        "hyprland/workspaces" = {
          format = "{name}";
          on-scroll-up = "hyprctl dispatch \"hl.dsp.focus({ workspace = 'm-1' })\"";
          on-scroll-down = "hyprctl dispatch \"hl.dsp.focus({ workspace = 'm+1' })\"";
        };

        network = {
          format-wifi = "Down: {bandwidthDownBits} | Up: {bandwidthUpBits}";
          format-ethernet = "Down: {bandwidthDownBits} | Up: {bandwidthUpBits}";
          format-disconnected = "OFFLINE";
          interval = 2;
          tooltip = false;
          on-click = "hyprctl dispatch \"hl.dsp.exec_cmd('kitty nmtui', { float = true, size = {512, 512} })\"";
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 35;
          separate-outputs = true;
        };

        mpris = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          player-icons = {
            default = "▶";
          };
          status-icons = {
            paused = "⏸";
          };
          max-length = 30;
          tooltip = false;
        };

        tray = {
          icon-size = 14;
          spacing = 8;
        };

        wireplumber = {
          format = "VOL {volume}%";
          format-muted = "MUTED";
          tooltip = false;
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        battery = {
          format = "BAT {capacity}%";
          format-charging = "CHG {capacity}%";
          interval = 5;
          tooltip = false;
          states = {
            warning = 30;
            critical = 15;
          };
        };

        "custom/dunst" = {
          exec = "if [ \"$(dunstctl is-paused)\" = true ]; then echo DND; fi";
          interval = 5;
          signal = 8;
          tooltip = false;
        };

        clock = {
          format = "{:%d/%m/%Y  %H:%M}";
          on-click = "dunstctl set-paused toggle";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='${c.fg}'><b>{}</b></span>";
              days = "<span color='${c.fg}'><b>{}</b></span>";
              weeks = "<span color='${c.fg}'><b>W{}</b></span>";
              weekdays = "<span color='${c.fg}'><b>{}</b></span>";
              today = "<span color='${c.accent}'><b><u>{}</u></b></span>";
            };
          };

          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_down";
            on-scroll-down = "shift_up";
          };
        };
      }
    ];

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font", "Courier New", monospace;
          font-size: 12px;
          font-weight: bold;
          min-height: 0;
      }

      window#waybar {
          background-color: ${c.bg};
          color: ${c.fg};
          border-bottom: 1px solid ${c.fg};
          padding: 0;
      }

      .modules-left,
      .modules-center,
      .modules-right {
          padding: 4px 2px;
      }

      #custom-nixos {
          background-color: ${c.bg};
          color: ${c.fg};
          padding: 0 8px;
          font-size: 16px;
          padding-right: 14px;
          margin-right: 6px;
          border: 1px solid ${c.fg};
      }

      #custom-nixos:hover {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      #workspaces {
          padding: 0;
          margin-right: 6px;
      }

      #workspaces button {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          margin: 0 2px;
          padding: 2px 8px;
          min-width: 16px;
      }

      #workspaces button:hover {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      #workspaces button.focused,
      #workspaces button.active {
          background-color: ${c.fg};
          color: ${c.bg};
          border: 1px solid ${c.fg};
      }

      #workspaces button.urgent {
          color: ${c.accent};
          border: 1px solid ${c.accent};
      }

      #network {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px 10px;
          margin-right: 6px;
      }

      #network.disconnected {
          color: ${c.dim};
          border-color: ${c.dim};
      }

      #window {
          background-color: ${c.bg};
          color: ${c.fg};
          padding: 2px 12px;
          border: 1px solid ${c.fg};
      }

      window#waybar.empty #window{
          border: transparent;
      }

      #mpris,
      #tray,
      #wireplumber,
      #battery,
      #custom-dunst,
      #clock {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px 10px;
          margin-left: 6px;
      }

      #wireplumber.muted {
          color: ${c.dim};
          border-color: ${c.dim};
      }

      #battery.warning:not(.charging) {
          border-color: ${c.accent};
      }

      #battery.critical:not(.charging) {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      #tray {
          padding: 2px 8px;
      }

      #custom-dunst {
          color: ${c.accent};
          border-color: ${c.accent};
      }

      #clock {
          background-color: ${c.fg};
          color: ${c.bg};
      }
    '';
  };
}
