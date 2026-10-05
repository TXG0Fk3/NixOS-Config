{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.fastfetch;
  inherit (cfg) keyColor;

  minimal = {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

    logo.source = "nixos_old_small";
    display.separator = "  ";

    modules = [
      "title"
      {
        type = "os";
        key = " OS ";
        inherit keyColor;
      }
      {
        type = "kernel";
        key = " KNL";
        inherit keyColor;
      }
      {
        type = "wm";
        key = " WM ";
        inherit keyColor;
      }
      {
        type = "packages";
        key = "󰏖 PKG";
        inherit keyColor;
      }
      {
        type = "uptime";
        format = "{2}h {3}m";
        key = " UP ";
        inherit keyColor;
      }
      {
        type = "memory";
        key = " MEM";
        inherit keyColor;
      }
      "break"
    ];
  };
in
{
  options.fastfetch.keyColor = lib.mkOption {
    type = lib.types.str;
    default = "36";
    example = "35";
    description = "Color of the keys (OS, KNL, WM...) for the minimal preset, in fastfetch color format.";
  };

  config.xdg.dataFile."fastfetch/presets/minimal.jsonc".source =
    (pkgs.formats.json { }).generate "fastfetch-minimal.jsonc"
      minimal;
}
