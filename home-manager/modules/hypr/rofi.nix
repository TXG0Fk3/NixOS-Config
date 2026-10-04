{ config, pkgs, ... }:

let
  c = import ./colors.nix;
in
{
  home.packages = with pkgs; [
    noto-fonts-color-emoji

    rofimoji

    wl-clipboard
    wtype
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  programs.rofi = {
    enable = true;

    settings = {
      modi = "drun,run";
      show-icons = false;
      font = "JetBrains Mono 10";
      drun-display-format = "{name}";
    };

    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
        bg = mkLiteral c.bg;
        fg = mkLiteral c.fg;
        dim = mkLiteral c.dim;
      in
      {
        "*" = {
          background-color = bg;
          text-color = fg;
          border-color = fg;
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          spacing = mkLiteral "0px";
        };

        window = {
          background-color = bg;
          border = mkLiteral "1px";
          border-color = fg;
          width = mkLiteral "450px";
          padding = mkLiteral "12px";
        };

        mainbox = {
          children = map mkLiteral [
            "inputbar"
            "listview"
          ];
        };

        inputbar = {
          border = mkLiteral "1px";
          border-color = fg;
          padding = mkLiteral "6px 10px";
          margin = mkLiteral "0px 0px 10px 0px";
          children = map mkLiteral [
            "prompt"
            "entry"
          ];
        };

        prompt = {
          padding = mkLiteral "0px 8px 0px 0px";
          text-color = mkLiteral "inherit";
        };

        entry = {
          placeholder = "Buscar...";
          placeholder-color = dim;
          text-color = fg;
        };

        listview = {
          lines = 8;
          columns = 1;
          scrollbar = false;
          spacing = mkLiteral "6px";
        };

        element = {
          padding = mkLiteral "6px 10px";
          border = mkLiteral "1px";
          border-color = fg;
          background-color = bg;
          text-color = fg;
        };

        "element selected" = {
          background-color = fg;
          text-color = bg;
          border = mkLiteral "1px";
          border-color = fg;
        };

        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
        };
      };
  };
}
