{ config, ... }:

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
          "clock"
        ];

        "custom/nixos" = {
          format = "";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{name}";
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
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        battery = {
          format = "BAT {capacity}%";
          format-charging = "CHG {capacity}%";
          interval = 5;
          tooltip = false;
        };

        clock = {
          format = "{:%d/%m/%Y  %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#FFFFFF'><b>{}</b></span>";
              days = "<span color='#FFFFFF'><b>{}</b></span>";
              weeks = "<span color='#FFFFFF'><b>W{}</b></span>";
              weekdays = "<span color='#FFFFFF'><b>{}</b></span>";
              today = "<span color='#00FEFF'><b><u>{}</u></b></span>";
            };
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
          background-color: #000000;
          color: #ffffff;
          border-bottom: 1px solid #ffffff;
          padding: 0;
      }

      .modules-left,
      .modules-center,
      .modules-right {
          padding: 4px 2px;
      }

      #custom-nixos {
          background-color: #000000;
          color: #ffffff;
          padding: 0 8px;
          font-size: 16px;
          padding-right: 14px;
          margin-right: 6px;
          border: 1px solid #ffffff;
      }

      #workspaces {
          padding: 0;
          margin-right: 6px;
      }

      #workspaces button {
          background-color: #000000;
          color: #ffffff;
          border: 1px solid #ffffff;
          margin: 0 2px;
          padding: 2px 8px;
          min-width: 16px;
      }

      #workspaces button:hover {
          background-color: #ffffff;
          color: #000000;
      }

      #workspaces button.focused,
      #workspaces button.active {
          background-color: #ffffff;
          color: #000000;
          border: 1px solid #ffffff;
      }

      #network {
          background-color: #000000;
          color: #ffffff;
          border: 1px solid #ffffff;
          padding: 2px 10px;
          margin-right: 6px;
      }

      #window {
          background-color: #000000;
          color: #ffffff;
          padding: 2px 12px;
          border: 1px solid #ffffff;
      }

      window#waybar.empty #window{
          border: transparent;
      }

      #mpris,
      #tray,
      #wireplumber,
      #battery,
      #clock {
          background-color: #000000;
          color: #ffffff;
          border: 1px solid #ffffff;
          padding: 2px 10px;
          margin-left: 6px;
      }

      #tray {
          padding: 2px 8px;
      }

      #clock {
          background-color: #ffffff;
          color: #000000;
      }
    '';
  };
}
