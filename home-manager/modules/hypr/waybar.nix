{
  config,
  colors,
  lib,
  pkgs,
  ...
}:

let
  c = colors;

  floatTerm =
    cmd: w: h:
    "hyprctl dispatch \"hl.dsp.exec_cmd('kitty ${cmd}', { float = true, size = {${toString w}, ${toString h}} })\"";

  tailscaleView = pkgs.writeShellScriptBin "tailscale-view" ''
    ${pkgs.tailscale}/bin/tailscale status
    echo ""
    read -n 1 -s -r -p "Press any key to close..."
  '';
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
        height = 42;
        spacing = 0;

        modules-left = [
          "custom/nixos"
          "hyprland/workspaces"
          "network"
          "hyprland/submap"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "mpris"
          "tray"
          "privacy"
          "wireplumber"
          "battery"
          "custom/hyprsunset"
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
          tooltip = false;
          on-scroll-up = "hyprctl dispatch \"hl.dsp.focus({ workspace = 'm-1' })\"";
          on-scroll-down = "hyprctl dispatch \"hl.dsp.focus({ workspace = 'm+1' })\"";
        };

        network = {
          format-wifi = "Down: {bandwidthDownBits} | Up: {bandwidthUpBits}";
          format-ethernet = "Down: {bandwidthDownBits} | Up: {bandwidthUpBits}";
          format-disconnected = "OFFLINE";
          interval = 2;
          tooltip = false;
          on-click = floatTerm "nmtui" 512 512;
        };

        "hyprland/submap" = {
          format = "{}";
          tooltip = false;
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 40;
          separate-outputs = true;
        };

        mpris = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          player-icons = {
            default = "󰐊";
          };
          status-icons = {
            paused = "󰏤";
          };
          max-length = 30;
          tooltip = false;
        };

        tray = {
          icon-size = 14;
          spacing = 8;
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 12;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 14;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 14;
            }
          ];
        };

        wireplumber = {
          format = "VOL {volume}%";
          format-muted = "MUTED";
          tooltip = false;
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = floatTerm "wiremix" 1000 600;
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

        "custom/hyprsunset" = {
          exec = "if pgrep -x hyprsunset >/dev/null; then echo SHD; fi";
          interval = 5;
          signal = 9;
          tooltip = false;
        };

        "custom/dunst" = {
          exec = "if [ \"$(dunstctl is-paused)\" = true ]; then echo DND; fi";
          interval = 5;
          signal = 8;
          tooltip = false;
        };

        clock = {
          format = "{:%d/%m/%Y  %H:%M}";
          on-click = "dunstctl set-paused toggle && pkill -RTMIN+8 waybar";
          on-click-middle = "if pkill -x hyprsunset; then while pgrep -x hyprsunset >/dev/null; do sleep 0.01; done; else hyprsunset -t 3500 </dev/null >/dev/null 2>&1 & fi && pkill -RTMIN+9 waybar";
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
    ]
    ++ lib.optional (config.hypr.secondaryMonitor != null) {
      output = config.hypr.secondaryMonitor;
      layer = "top";
      position = "bottom";
      height = 42;
      spacing = 0;

      modules-left = [
        "custom/fps"
        "custom/cpu"
        "custom/gpu"
        "custom/vram"
        "memory"
      ];
      modules-center = [ ];
      modules-right = [
        "custom/tailscale"
        "custom/hydra"
      ];

      "custom/fps" = {
        exec = pkgs.writeShellScript "waybar-fps" ''
          uid=$(id -u)
          now=$(date +%s)
          latest_fps=""
          latest_mtime=0

          for dir in "/run/user/$uid/mangohud" "${config.xdg.cacheHome}/mangohud"; do
            mkdir -p "$dir"
            for f in "$dir"/*.csv; do
              [ -f "$f" ] || continue
              case "$f" in *_summary.csv) rm -f "$f"; continue ;; esac
              mtime=$(stat -c %Y "$f" 2>/dev/null || echo 0)
              age=$(( now - mtime ))
              if [ "$age" -gt 5 ]; then
                [ "$age" -gt 60 ] && rm -f "$f"
                continue
              fi
              if [ "$mtime" -ge "$latest_mtime" ]; then
                line=$(tail -n 1 "$f" 2>/dev/null)
                fps=''${line%%,*}
                case "$fps" in
                  [0-9]*)
                    latest_mtime=$mtime
                    latest_fps=''${fps%%.*}
                    ;;
                esac
              fi
            done
          done

          if [ -n "$latest_fps" ]; then
            echo "FPS $latest_fps"
          fi
        '';
        interval = 2;
        tooltip = false;
      };

      "custom/cpu" = {
        exec = pkgs.writeShellScript "waybar-cpu" ''
          uid=$(id -u)
          prev_file="/run/user/$uid/waybar-cpu-prev"
          read -r _ u n s i w q sq _ < /proc/stat
          total=$(( u + n + s + i + w + q + sq ))
          idle=$(( i + w ))

          if [ -r "$prev_file" ]; then
            read -r p_total p_idle < "$prev_file"
            diff_total=$(( total - p_total ))
            diff_idle=$(( idle - p_idle ))
            if [ "$diff_total" -gt 0 ]; then
              usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
            else
              usage=0
            fi
          else
            usage=0
          fi
          echo "$total $idle" > "$prev_file"

          temp=""
          for h in /sys/class/hwmon/hwmon*; do
            name=$(cat "$h/name" 2>/dev/null)
            if [ "$name" = "k10temp" ] || [ "$name" = "coretemp" ]; then
              t=$(cat "$h/temp1_input" 2>/dev/null)
              [ -n "$t" ] && temp=" $(( t / 1000 ))°C"
              break
            fi
          done

          echo "CPU $usage%$temp"
        '';
        interval = 2;
        tooltip = false;
        on-click = floatTerm "btop" 1000 600;
      };

      "custom/gpu" = {
        exec = pkgs.writeShellScript "waybar-gpu" ''
          usage=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n 1)
          [ -n "$usage" ] || usage=0
          temp=$(cat /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1)
          [ -n "$temp" ] && temp=" $(( temp / 1000 ))°C" || temp=""
          echo "GPU $usage%$temp"
        '';
        interval = 2;
        tooltip = false;
        on-click = floatTerm "btop" 1000 600;
      };

      "custom/vram" = {
        exec = pkgs.writeShellScript "waybar-vram" ''
          for d in /sys/class/drm/card*/device; do
            [ -r "$d/mem_info_vram_used" ] || continue
            used=$(cat "$d/mem_info_vram_used")
            total=$(cat "$d/mem_info_vram_total")
            echo "VRAM $(( used / 1048576 ))/$(( total / 1048576 )) MB"
            exit 0
          done
          echo "VRAM N/A"
        '';
        interval = 2;
        tooltip = false;
        on-click = floatTerm "btop" 1000 600;
      };

      memory = {
        format = "RAM {used:0.1f}/{total:0.0f} GB";
        interval = 2;
        tooltip = false;
        on-click = floatTerm "btop" 1000 600;
      };

      "custom/tailscale" = {
        exec = pkgs.writeShellScript "waybar-tailscale" ''
          if ip=$(${pkgs.tailscale}/bin/tailscale ip -4 2>/dev/null); then
            echo "{\"text\":\"TS: $ip\",\"class\":\"connected\",\"tooltip\":\"Tailscale: Connected ($ip)\"}"
          else
            echo "{\"text\":\"TS: OFF\",\"class\":\"disconnected\",\"tooltip\":\"Tailscale: Disconnected\"}"
          fi
        '';
        return-type = "json";
        interval = 10;
        tooltip = true;
        on-click = floatTerm "${tailscaleView}/bin/tailscale-view" 800 500;
      };

      "custom/hydra" = {
        exec = pkgs.writeShellScript "waybar-hydra" ''
          code=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 --max-time 3 https://hydra.txgfk.xyz || echo "000")
          if [ "$code" = "200" ]; then
            lat=$(${pkgs.iputils}/bin/ping -c 1 -W 1 hydra.txgfk.xyz 2>/dev/null | ${pkgs.gawk}/bin/gawk -F'/' '/rtt/{ printf "%.0fms", $5 }')
            [ -n "$lat" ] || lat="UP"
            echo "{\"text\":\"HYDRA: $lat\",\"class\":\"online\",\"tooltip\":\"Hydra: Online ($lat) - https://hydra.txgfk.xyz\"}"
          else
            echo '{"text":"HYDRA: DOWN","class":"offline","tooltip":"Hydra: Offline or HTTP Error"}'
          fi
        '';
        return-type = "json";
        interval = 15;
        tooltip = true;
        on-click = "uwsm app -- librewolf https://hydra.txgfk.xyz";
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          box-shadow: none;
          text-shadow: none;
          transition: none;
          font-family: "JetBrainsMono Nerd Font", "Courier New", monospace;
          font-size: 12px;
          font-weight: bold;
          min-height: 0;
      }

      window#waybar {
          background-color: ${c.bg};
          color: ${c.fg};
          padding: 0;
      }

      window#waybar.top {
          border-bottom: 1px solid ${c.fg};
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

      #workspaces {
          padding: 0;
          margin-right: 6px;
      }

      #workspaces button {
          background-color: ${c.bg};
          background-image: none;
          color: ${c.fg};
          border: 1px solid ${c.fg};
          margin: 0 2px;
          padding: 2px 8px;
          min-width: 16px;
      }

      #workspaces button.focused,
      #workspaces button.active {
          background-color: ${c.fg};
          background-image: none;
          color: ${c.bg};
          border: 1px solid ${c.fg};
      }

      #workspaces button.urgent {
          color: ${c.accent};
          border: 1px solid ${c.accent};
      }

      #workspaces button:hover {
          background-color: ${c.fg};
          background-image: none;
          color: ${c.bg};
          border: 1px solid ${c.fg};
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

      #network:hover {
          background-color: ${c.fg};
          color: ${c.bg};
          border-color: ${c.fg};
      }

      #submap {
          background-color: ${c.bg};
          color: ${c.accent};
          border: 1px solid ${c.accent};
          padding: 2px 10px;
          margin-right: 6px;
      }

      #window {
          background-color: ${c.bg};
          color: ${c.fg};
          padding: 2px 12px;
          border: 1px solid ${c.fg};
      }

      window#waybar.empty #window {
          border: transparent;
      }

      #mpris,
      #tray,
      #wireplumber,
      #battery,
      #custom-hyprsunset,
      #custom-dunst,
      #clock {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px 10px;
          margin-left: 6px;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 2px 6px;
          margin-left: 6px;
          border: 1px solid ${c.accent};
          color: ${c.accent};
      }

      #privacy-item.screenshare {
          border-color: ${c.yellow};
          color: ${c.yellow};
      }

      #privacy-item.audio-in {
          border-color: ${c.red};
          color: ${c.red};
      }

      #wireplumber.muted {
          color: ${c.dim};
          border-color: ${c.dim};
      }

      #wireplumber:hover {
          background-color: ${c.fg};
          color: ${c.bg};
          border-color: ${c.fg};
      }

      #mpris:hover {
          background-color: ${c.fg};
          color: ${c.bg};
          border-color: ${c.fg};
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

      #custom-hyprsunset,
      #custom-dunst {
          color: ${c.accent};
          border-color: ${c.accent};
      }

      #clock {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      tooltip {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 4px 8px;
      }

      tooltip label {
          color: ${c.fg};
      }

      menu {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px;
      }

      menuitem {
          background-color: ${c.bg};
          color: ${c.fg};
          padding: 4px 10px;
      }

      menuitem:hover,
      menuitem:hover * {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      menuitem:disabled,
      menuitem:disabled * {
          color: ${c.dim};
      }

      menu separator {
          background-color: ${c.dim};
      }

      /* ─── Second Monitor (Bottom Bar) ─── */
      window#waybar.bottom {
          border-top: 1px solid ${c.fg};
      }

      #custom-fps,
      #custom-cpu,
      #custom-gpu,
      #custom-vram,
      #memory {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px 10px;
          margin-right: 6px;
      }

      #custom-fps {
          color: ${c.accent};
          border-color: ${c.accent};
      }

      #custom-tailscale,
      #custom-hydra {
          background-color: ${c.bg};
          color: ${c.fg};
          border: 1px solid ${c.fg};
          padding: 2px 10px;
          margin-left: 6px;
      }

      #custom-hydra.online {
          color: ${c.accent};
          border-color: ${c.accent};
      }

      #custom-hydra.offline {
          color: ${c.red};
          border-color: ${c.red};
      }

      #custom-tailscale.connected {
          color: ${c.accent};
          border-color: ${c.accent};
      }

      #custom-tailscale.disconnected {
          color: ${c.dim};
          border-color: ${c.dim};
      }

      /* Waybar 0.16 puts hover on the wrapper, not the named label: https://github.com/Alexays/Waybar/issues/5459 */
      box:hover > #custom-nixos,
      box:hover > #custom-fps,
      box:hover > #custom-cpu,
      box:hover > #custom-gpu,
      box:hover > #custom-vram,
      box:hover > #custom-tailscale,
      box:hover > #custom-hydra {
          background-color: ${c.fg};
          color: ${c.bg};
      }

      #memory:hover {
          background-color: ${c.fg};
          color: ${c.bg};
      }
    '';
  };
}
