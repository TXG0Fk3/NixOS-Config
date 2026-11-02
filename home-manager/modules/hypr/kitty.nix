{ colors, ... }:

let
  c = colors;
in
{
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12.0;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      cursor_trail = 1;

      linux_display_server = "auto";

      scrollback_lines = 2000;
      wheel_scroll_min_lines = 1;

      enable_audio_bell = false;

      window_padding_width = 4;

      confirm_os_window_close = 0;

      # Colors
      background = c.bg;
      foreground = c.fg;
      selection_background = c.fg;
      selection_foreground = c.bg;
      url_color = c.accent;
      cursor = c.accent;
      cursor_text_color = c.bg;

      # Tabs
      tab_bar_style = "separator";
      tab_separator = " │ ";
      active_tab_background = c.fg;
      active_tab_foreground = c.bg;
      active_tab_font_style = "bold";
      inactive_tab_background = c.bg;
      inactive_tab_foreground = c.dim;
      inactive_tab_font_style = "normal";
      tab_bar_background = c.bg;

      # Black
      color0 = c.bg;
      color8 = c.dim;

      # Red
      color1 = c.red;
      color9 = c.red;

      # Green
      color2 = c.green;
      color10 = c.green;

      # Yellow
      color3 = c.yellow;
      color11 = c.yellow;

      # Blue
      color4 = c.blue;
      color12 = c.blue;

      # Magenta
      color5 = c.pink;
      color13 = c.pink;

      # Cyan
      color6 = c.accent;
      color14 = c.accent;

      # White
      color7 = c.fg;
      color15 = c.fg;
    };
  };
}
