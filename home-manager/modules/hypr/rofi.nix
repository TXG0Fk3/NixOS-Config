{ config, pkgs, ... }:

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
      in
      {
        "*" = {
          background-color = mkLiteral "#000000";
          text-color = mkLiteral "#ffffff";
          border-color = mkLiteral "#ffffff";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          spacing = mkLiteral "0px";
        };

        window = {
          background-color = mkLiteral "#000000";
          border = mkLiteral "1px";
          border-color = mkLiteral "#ffffff";
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
          border-color = mkLiteral "#ffffff";
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
          placeholder-color = mkLiteral "#666666";
          text-color = mkLiteral "#ffffff";
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
          border-color = mkLiteral "#ffffff";
          background-color = mkLiteral "#000000";
          text-color = mkLiteral "#ffffff";
        };

        "element selected" = {
          background-color = mkLiteral "#ffffff";
          text-color = mkLiteral "#000000";
          border = mkLiteral "1px";
          border-color = mkLiteral "#ffffff";
        };

        element-text = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
        };
      };
  };
}
