{ pkgs, ... }:

let
  focusDuration = 1500;
  breakDuration = 300;
  longBreakDuration = 900;
  chime = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga";

  focusMode = pkgs.writeShellScriptBin "focus-mode" ''
    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/focus-mode"
    state_file="$state_dir/state"
    pid_file="$state_dir/pid"

    refresh_waybar() {
      ${pkgs.procps}/bin/pkill -RTMIN+10 waybar 2>/dev/null || true
      ${pkgs.procps}/bin/pkill -RTMIN+8 waybar 2>/dev/null || true
    }

    kill_watcher() {
      if [ -r "$pid_file" ]; then
        read -r pid < "$pid_file" || true
        [ -n "''${pid:-}" ] && kill "$pid" 2>/dev/null || true
        rm -f "$pid_file"
      fi
    }

    start_phase() {
      local phase="$1"
      local duration="$2"
      local prev_pause="$3"
      local token end

      kill_watcher
      token="$(${pkgs.coreutils}/bin/date +%s%N)-$$"
      end=$(( $(${pkgs.coreutils}/bin/date +%s) + duration ))
      printf '%s %s %s %s\n' "$phase" "$end" "$prev_pause" "$token" > "$state_file"

      if [ "$phase" = "focus" ]; then
        ${pkgs.dunst}/bin/dunstctl set-pause-level 60
      fi

      ${pkgs.coreutils}/bin/nohup ${pkgs.bash}/bin/bash -c \
        'sleep "$1" && exec "$2" _advance "$3"' _ "$duration" "$0" "$token" \
        </dev/null >/dev/null 2>&1 &
      echo "$!" > "$pid_file"

      refresh_waybar
    }

    stop_session() {
      local prev_pause=0
      if [ -r "$state_file" ]; then
        read -r _ _ prev_pause _ < "$state_file" || true
      fi
      kill_watcher
      rm -f "$state_file"
      ${pkgs.dunst}/bin/dunstctl set-pause-level "''${prev_pause:-0}"
      refresh_waybar
    }

    start_focus_new() {
      local prev_pause
      mkdir -p "$state_dir"
      prev_pause=$(${pkgs.dunst}/bin/dunstctl get-pause-level 2>/dev/null || echo 0)
      start_phase focus ${toString focusDuration} "$prev_pause"
      ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u normal -t 3000 "FOCUS" "25:00 — DND enabled"
    }

    case "''${1:-}" in
      toggle)
        if [ -f "$state_file" ]; then
          stop_session
          ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u low -t 2500 "FOCUS" "Session ended"
        else
          start_focus_new
        fi
        ;;
      next)
        if [ ! -f "$state_file" ]; then
          start_focus_new
        else
          read -r phase _ prev_pause _ < "$state_file"
          if [ "$phase" = "focus" ]; then
            start_phase break ${toString breakDuration} "$prev_pause"
            ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u normal -t 3000 "BREAK" "05:00"
          else
            start_phase focus ${toString focusDuration} "$prev_pause"
            ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u normal -t 3000 "FOCUS" "25:00 — DND enabled"
          fi
        fi
        ;;
      long-break)
        mkdir -p "$state_dir"
        if [ -r "$state_file" ]; then
          read -r _ _ prev_pause _ < "$state_file" || true
        else
          prev_pause=$(${pkgs.dunst}/bin/dunstctl get-pause-level 2>/dev/null || echo 0)
        fi
        start_phase break ${toString longBreakDuration} "''${prev_pause:-0}"
        ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u normal -t 3000 "LONG BREAK" "15:00"
        ;;
      _advance)
        expected="''${2:-}"
        [ -f "$state_file" ] || exit 0
        read -r phase _ prev_pause token < "$state_file"
        [ "$token" = "$expected" ] || exit 0

        ${pkgs.pipewire}/bin/pw-play "${chime}" >/dev/null 2>&1 &

        if [ "$phase" = "focus" ]; then
          start_phase break ${toString breakDuration} "$prev_pause"
          ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u critical "FOCUS COMPLETE" "Break time — 05:00"
        else
          stop_session
          ${pkgs.dunst}/bin/dunstify -a "focus-mode" -r 2596 -u critical "BREAK OVER" "Ready for next focus block"
        fi
        ;;
      status)
        [ -f "$state_file" ] || exit 0
        read -r phase end _ _ < "$state_file"
        now=$(${pkgs.coreutils}/bin/date +%s)
        rem=$(( end - now ))
        [ "$rem" -lt 0 ] && rem=0
        timer=$(printf '%02d:%02d' $(( rem / 60 )) $(( rem % 60 )))
        if [ "$phase" = "focus" ]; then
          printf '{"text":"FOC %s","class":"focus"}\n' "$timer"
        else
          printf '{"text":"BRK %s","class":"break"}\n' "$timer"
        fi
        ;;
    esac
  '';
in
{
  home.packages = [ focusMode ];
}
