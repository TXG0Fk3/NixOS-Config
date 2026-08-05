{ config, pkgs, ... }:

{
  # https://github.com/NixOS/nixpkgs/blob/8c91a71d13451abc40eb9dae8910f972f979852f/nixos/modules/services/x11/desktop-managers/xfce.nix
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableXfwm = false;
    enableWaylandSession = true;
    waylandSessionCompositor = "labwc --startup";
  };

  environment.systemPackages = with pkgs; [
    # XFCE Essentials
    garcon
    xfce4-whiskermenu-plugin
    xfconf

    # Programs
    gnome-disk-utility
    mousepad
    thunar
  ];

  environment.xfce.excludePackages = with pkgs.xfce; [
    hicolor-icon-theme
    tango-icon-theme
    xfce4-icon-theme
  ];
}
