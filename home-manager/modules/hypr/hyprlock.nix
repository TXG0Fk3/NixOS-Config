{ config, lib, ... }:

let
  c = import ./colors.nix;

  col = hex: "rgb(${lib.removePrefix "#" hex})";
  white = col c.fg;
  black = col c.bg;

  m = config.hypr.primaryMonitor;
  font = "JetBrainsMono Nerd Font Mono";
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          monitor = "";
          color = black;
        }
      ];

      shape = [
        {
          monitor = m;
          size = "340, 150";
          color = white;
          rounding = 0;
          border_size = 0;
          position = "0, 130";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = m;
          text = "cmd[update:1000] date +%H:%M";
          font_family = font;
          font_size = 56;
          color = black;
          position = "0, 155";
          halign = "center";
          valign = "center";
        }
        {
          monitor = m;
          text = "cmd[update:60000] date +%d/%m/%Y";
          font_family = font;
          font_size = 16;
          color = black;
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = m;
          size = "340, 48";
          position = "0, 0";
          halign = "center";
          valign = "center";

          outline_thickness = 1;
          rounding = 0;
          outer_color = white;
          inner_color = black;
          font_color = white;
          check_color = white;
          fail_color = white;

          dots_size = 0.25;
          dots_spacing = 0.3;
          dots_center = true;
          dots_rounding = 0;

          fade_on_empty = false;
          placeholder_text = "PASSWORD";
          fail_text = "WRONG ($ATTEMPTS)";
          font_family = font;
        }
      ];
    };
  };
}
