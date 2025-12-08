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
    gnomeExtensions.appindicator
    gnomeExtensions.background-logo
    gnomeExtensions.blur-my-shell
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.day-progress
    gnomeExtensions.just-perfection
    gnomeExtensions.logo-menu
    gnomeExtensions.media-controls
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.space-bar
    gnomeExtensions.user-themes
    gnomeExtensions.vertical-workspaces
    gnomeExtensions.vitals
    gnomeExtensions.window-title-is-back

    # Gnome Stuff
    gnome-console
    gnome-disk-utility
    gnome-tweaks
    mission-center
    nautilus
  ];

  # Other
  environment.extraInit = ''
    export XDG_DATA_DIRS="${pkgs.gtk3}/share/gsettings-schemas/gtk+3-${pkgs.gtk3.version}:$XDG_DATA_DIRS"
    export GTK_IM_MODULE=simple
  '';
}