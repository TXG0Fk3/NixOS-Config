{ ... }:

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
    };
  };
}
