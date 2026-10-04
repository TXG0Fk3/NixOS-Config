{ pkgs, ... }:

{
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };

  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  security.polkit.enable = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    ly.enableGnomeKeyring = true;
    hyprlock = { };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
