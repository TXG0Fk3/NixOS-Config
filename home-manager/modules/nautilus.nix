{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nautilus
    ffmpegthumbnailer
    gdk-pixbuf
    libheif
    webp-pixbuf-loader
  ];

  dconf.settings = {
    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };
  };

  systemd.user.tmpfiles.rules = [
    "e %h/.local/share/Trash/files - - - 30d -"
    "e %h/.local/share/Trash/info - - - 30d -"
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
  };
}
