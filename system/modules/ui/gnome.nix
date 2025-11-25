{ config, pkgs, ... }:

{
  # UI
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    gnome.core-apps.enable = false;
  };
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  environment.systemPackages = with pkgs; [
    # Gnome Extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.logo-menu
    gnomeExtensions.space-bar
    gnomeExtensions.appindicator
    gnomeExtensions.window-title-is-back
    gnomeExtensions.background-logo
    gnomeExtensions.rounded-window-corners-reborn

    # Gnome Stuff
    gnome-console
    gnome-disk-utility
    gnome-tweaks
    mission-center
    nautilus
  ];

  environment.extraInit = ''
    export XDG_DATA_DIRS="${pkgs.gtk3}/share/gsettings-schemas/gtk+3-${pkgs.gtk3.version}:$XDG_DATA_DIRS"
  '';
}