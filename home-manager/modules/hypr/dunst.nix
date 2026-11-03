{
  config,
  colors,
  pkgs,
  ...
}:

let
  c = colors;

  volumeOsd = pkgs.writeShellScriptBin "volume-osd" ''
    case "$1" in
      up)   ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
      down) ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
      mute) ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac

    out=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if [[ "$out" == *"[MUTED]"* ]]; then
      ${pkgs.dunst}/bin/dunstify -a "volume-osd" -r 2593 -u low -t 1500 "VOLUME" "MUTED"
    else
      raw="''${out#Volume: }"
      raw="''${raw//./}"
      vol=$((10#$raw))
      ${pkgs.dunst}/bin/dunstify -a "volume-osd" -r 2593 -u normal -t 1500 \
        -h int:value:"$vol" "VOLUME" "''${vol}%"
    fi
  '';
in
{
  home.packages = [ volumeOsd ];

  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = config.hypr.primaryMonitor;
        font = "JetBrains Mono 10";
        allow_markup = true;
        format = "<b>%s</b>\\n%b";
        sort = true;
        indicate_missing = true;
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;

        width = "(300, 380)";
        height = 150;
        offset = "10x10";
        origin = "top-right";
        notification_limit = 5;

        corner_radius = 0;
        border_size = 1;
        padding = 12;
        horizontal_padding = 16;
        text_icon_padding = 10;
        frame_width = 1;

        gap_size = 6;

        icon_position = "left";
        max_icon_size = 32;

        progress_bar = true;
        progress_bar_height = 8;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 0;
        highlight = c.accent;
      };

      urgency_low = {
        background = c.bg;
        foreground = c.fg;
        frame_color = c.dim;
        timeout = 4;
      };

      urgency_normal = {
        background = c.bg;
        foreground = c.fg;
        frame_color = c.fg;
        timeout = 6;
      };

      urgency_critical = {
        background = c.fg;
        foreground = c.bg;
        frame_color = c.fg;
        timeout = 0;
      };
    };
  };
}
