{ config, ... }:

{
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
      };

      urgency_low = {
        background = "#000000";
        foreground = "#ffffff";
        frame_color = "#ffffff";
        timeout = 4;
      };

      urgency_normal = {
        background = "#000000";
        foreground = "#ffffff";
        frame_color = "#ffffff";
        timeout = 6;
      };

      urgency_critical = {
        background = "#ffffff";
        foreground = "#000000";
        frame_color = "#ffffff";
        timeout = 0;
      };
    };
  };
}
