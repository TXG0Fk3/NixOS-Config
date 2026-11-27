{ pkgs, ... }:

let
  zenMode = pkgs.writeShellScriptBin "zen-mode" ''
    set -u

    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/zen-mode"
    state_file="$state_dir/state"

    systemctl="${pkgs.systemd}/bin/systemctl"
    dunstctl="${pkgs.dunst}/bin/dunstctl"
    dunstify="${pkgs.dunst}/bin/dunstify"

    is_active() {
      "$systemctl" --user is-active --quiet "$1"
    }

    apply_zen_hypr() {
      hyprctl eval 'hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 }, animations = { enabled = false } })' >/dev/null 2>&1 || true
    }

    enter_zen() {
      mkdir -p "$state_dir"

      local had_waybar=0 had_hyprpaper=0 prev_pause=0

      is_active waybar.service && had_waybar=1
      is_active hyprpaper.service && had_hyprpaper=1
      prev_pause=$("$dunstctl" get-pause-level 2>/dev/null || echo 0)

      cat > "$state_file" <<EOF
    had_waybar=$had_waybar
    had_hyprpaper=$had_hyprpaper
    prev_pause=$prev_pause
    EOF

      [ "$had_waybar" = 1 ] && "$systemctl" --user stop waybar.service 2>/dev/null || true
      [ "$had_hyprpaper" = 1 ] && "$systemctl" --user stop hyprpaper.service 2>/dev/null || true

      apply_zen_hypr

      "$dunstctl" set-pause-level 60 2>/dev/null || true
      "$dunstify" -a "zen-mode" -r 2597 -u normal -t 2000 "ZEN / GAMING" "Enabled"
    }

    exit_zen() {
      local had_waybar=1 had_hyprpaper=1 prev_pause=0

      if [ -r "$state_file" ]; then
        # shellcheck disable=SC1090
        . "$state_file"
        rm -f "$state_file"
      fi

      hyprctl eval 'hl.config({ general = { gaps_in = 5, gaps_out = 10, border_size = 1 }, animations = { enabled = true } })' >/dev/null 2>&1 || true

      "$dunstctl" set-pause-level "''${prev_pause:-0}" 2>/dev/null || true
      "$systemctl" --user reset-failed waybar.service hyprpaper.service 2>/dev/null || true

      [ "$had_hyprpaper" = 1 ] && "$systemctl" --user start hyprpaper.service 2>/dev/null || true
      [ "$had_waybar" = 1 ] && "$systemctl" --user start waybar.service 2>/dev/null || true

      "$dunstify" -a "zen-mode" -r 2597 -u low -t 2000 "ZEN / GAMING" "Disabled"
    }

    case "''${1:-toggle}" in
      toggle)
        if [ -f "$state_file" ]; then
          exit_zen
        else
          enter_zen
        fi
        ;;
      on)
        [ -f "$state_file" ] || enter_zen
        ;;
      off)
        [ -f "$state_file" ] && exit_zen
        ;;
      reapply)
        if [ -f "$state_file" ]; then
          apply_zen_hypr
        fi
        ;;
      status)
        if [ -f "$state_file" ]; then
          echo "on"
        else
          echo "off"
        fi
        ;;
    esac
  '';
in
{
  home.packages = [ zenMode ];
}
