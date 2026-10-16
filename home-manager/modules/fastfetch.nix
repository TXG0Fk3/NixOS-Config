{
  config,
  lib,
  pkgs,
  ...
}:

let
  keyColor = "white";

  minimal = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

    logo = {
      source = "nixos_old_small";
      color = {
        "1" = "white";
        "2" = "white";
      };
    };

    display = {
      separator = "  ";
      color = {
        keys = keyColor;
        title = keyColor;
        output = keyColor;
        separator = keyColor;
      };
    };

    modules = [
      "title"
      {
        type = "os";
        key = " OS ";
      }
      {
        type = "kernel";
        key = " KNL";
      }
      {
        type = "wm";
        key = " WM ";
      }
      {
        type = "packages";
        key = "󰏖 PKG";
      }
      {
        type = "uptime";
        format = "{2}h {3}m";
        key = " UP ";
      }
      {
        type = "memory";
        key = " MEM";
      }
      "break"
    ];
  };
in
{
  xdg.dataFile."fastfetch/presets/minimal.jsonc".source =
    (pkgs.formats.json { }).generate "fastfetch-minimal.jsonc"
      minimal;
}
