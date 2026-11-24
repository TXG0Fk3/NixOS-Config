{
  config,
  colors,
  pkgs,
  lib,
  home-modules,
  ...
}:

let
  cfg = config.hypr;
  c = colors;
  col = hex: "0xFF${lib.removePrefix "#" hex}";

  luaColors = ''
    local colors = {
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: value: "    ${name} = \"${lib.toLower (lib.removePrefix "#" value)}\","
      ) colors
    )}
    }

    local function rgba(hex, alpha)
        return "rgba(" .. hex .. (alpha or "ff") .. ")"
    end
  '';
in
{
  imports = [
    ./dunst.nix
    ./hyprlock.nix
    ./kitty.nix
    ./ocr.nix
    ./satty.nix
    ./rofi.nix
    ./waybar.nix
    ./gtk.nix
    ./qt.nix
    (home-modules + "/nautilus.nix")
    (home-modules + "/edged.nix")
  ];

  options.hypr.primaryMonitor = lib.mkOption {
    type = lib.types.str;
    description = "Default output name (e.g. DP-1).";
  };
  options.hypr.secondaryMonitor = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Optional secondary output name (e.g. HDMI-A-1).";
  };
  options.hypr.extraLuaConfig = lib.mkOption {
    type = lib.types.path;
    description = "Path to a .lua file containing extra hyprland configuration. Set host monitors here.";
  };

  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;

      systemd.enable = false;

      configType = "lua";
      extraConfig = ''
        ${luaColors}
        ${builtins.readFile cfg.extraLuaConfig}
        ${builtins.readFile ./hypr.lua}
      '';
    };

    # Packages
    home.packages = with pkgs; [
      awww
      hyprpicker
      hyprshot
      hyprsunset

      wiremix
      playerctl
      xdg-user-dirs
      zenity

      (callPackage (home-modules + "/packages/hatter-icon-theme.nix") { })
    ];

    # Themes
    home.sessionVariables = {
      ADW_DISABLE_PORTAL = "1";
    };
    gtk = {
      enable = true;
      iconTheme.name = "Hatter-Slate";
      colorScheme = "dark";
    };
    qt = {
      enable = true;
      platformTheme.name = "qtct";
    };

    # Cursors
    home.pointerCursor = {
      enable = true;
      name = "Simp1e-Dark";
      package = pkgs.simp1e-cursors;
      size = 24;
      gtk.enable = true;
      hyprcursor.enable = true;
    };

    # Wallpapers
    services.awww.enable = true;

    # Polkit
    services.hyprpolkitagent.enable = true;

    # Hyprtoolkit
    xdg.configFile."hypr/hyprtoolkit.conf".text = ''
      background = ${col c.bg}
      base = ${col c.layer1}
      alternate_base = ${col c.layer2}
      text = ${col c.fg}
      bright_text = ${col c.fg}
      link_text = ${col c.accent}
      accent = ${col c.accent}
      accent_secondary = ${col c.fg}
      rounding_large = 0
      rounding_small = 0
      font_family = JetBrainsMono Nerd Font
      font_family_monospace = JetBrainsMono Nerd Font Mono
      icon_theme = Hatter-Slate
    '';
  };
}
