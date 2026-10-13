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
        title = "white";
        output = "white";
        separator = "white";
      };
    };

    modules = [
      "title"
      {
        type = "os";
        key = " OS ";
        keyColor = keyColor;
      }
      {
        type = "kernel";
        key = " KNL";
        keyColor = keyColor;
      }
      {
        type = "wm";
        key = " WM ";
        keyColor = keyColor;
      }
      {
        type = "packages";
        key = "󰏖 PKG";
        keyColor = keyColor;
      }
      {
        type = "uptime";
        format = "{2}h {3}m";
        key = " UP ";
        keyColor = keyColor;
      }
      {
        type = "memory";
        key = " MEM";
        keyColor = keyColor;
      }
      "break"
    ];
  };
in
{
  options.fastfetch.keyColor = lib.mkOption {
    type = lib.types.str;
    default = "white";
    example = "bright_white";
    description = "Color of the keys (OS, KNL, WM...) for the minimal preset.";
  };

  config = {
    xdg.dataFile."fastfetch/presets/minimal.jsonc".source =
      (pkgs.formats.json { }).generate "fastfetch-minimal.jsonc"
        minimal;

    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
