{
  config,
  pkgs,
  lib,
  home-modules,
  ...
}:

with lib;

let
  cfg = config.hypr;
in
{
  imports = [
    ./dunst.nix
    ./kitty.nix
    ./rofi.nix
    ./waybar.nix
  ];

  options.hypr.primaryMonitor = mkOption {
    type = types.str;
    description = "Default output name (e.g. DP-1).";
  };
  options.hypr.extraLuaConfig = mkOption {
    type = types.path;
    description = "Path to a .lua file containing extra hyprland configuration. Set host monitors here.";
  };

  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;

      configType = "lua";
      extraConfig = ''
        ${builtins.readFile cfg.extraLuaConfig}
        ${builtins.readFile ./hypr.lua}
      '';
    };

    # Packages
    home.packages = with pkgs; [
      awww
      hyprlock
      hyprpicker
      hyprshot

      pavucontrol
      playerctl
      superfile
      xdg-user-dirs
      zenity

      (callPackage (home-modules + "/packages/hatter-icon-theme.nix") { })
    ];

    # Themes
    home.sessionVariables = {
      GTK_THEME = "adw-gtk3-dark";
      ADW_DISABLE_PORTAL = "1";
    };
    gtk = {
      enable = true;
      iconTheme.name = "Hatter-Blue";
      theme.name = "adw-gtk3-dark";
      colorScheme = "dark";
    };
    qt = {
      enable = true;
      style.name = "adwaita-dark";
    };

    # Cursors
    home.pointerCursor = {
      enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      hyprcursor.enable = true;
    };

    # Wallpapers
    services.awww.enable = true;
  };
}
