{
  config,
  pkgs,
  lib,
  home-modules,
  ...
}:

let
  cfg = config.hypr;
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

      btop
      wiremix
      playerctl
      xdg-user-dirs
      zenity

      nerd-fonts.jetbrains-mono

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
  };
}
