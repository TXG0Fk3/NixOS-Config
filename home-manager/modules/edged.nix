{
  colors,
  pkgs,
  inputs,
  ...
}:

let
  c = colors;
in
{
  imports = [ inputs.edged.homeManagerModules.default ];

  programs.edged = {
    enable = true;

    settings = {
      general = {
        default_mode = "spacing";
        close_on_copy = true;
      };

      monitor = {
        target = "focused";
        crop_to_monitor = true;
      };

      capture = {
        method = "custom";
        command = "${pkgs.hyprshot}/bin/hyprshot -m output -s --raw > %s";
        timeout_seconds = 5;
      };

      ruler = {
        initial_tolerance = 15;
        tolerance_step = 2;
        draw_feet = true;
        feet_size = 6.0;
        line_thickness = 1.0;
        draw_crosshair = true;
      };

      bounds = {
        shift_pins_bounds = true;
        border_thickness = 1.0;
      };

      appearance = {
        overlay_opacity = 0.05;

        line_color = c.accent;
        line_shadow_color = "${c.bg}99";

        bounds_fill_color = "${c.accent}1F";
        bounds_border_color = c.accent;

        label_bg_color = c.bg;
        label_text_color = c.fg;
        label_border_color = c.fg;
        label_font_family = "JetBrainsMono Nerd Font";
        label_font_size = 12.0;
        label_border_radius = 0.0;
        label_padding_x = 7.0;
        label_padding_y = 3.5;
      };

      units = {
        show_pixel_unit = true;
        secondary_unit = "none";
        screen_dpi = 96.0;
      };

      clipboard = {
        format = "compact";
      };

      logging = {
        enabled = true;
        level = "info";
        retention_days = 2;
        log_to_console = true;
        log_to_file = true;
      };
    };
  };
}
