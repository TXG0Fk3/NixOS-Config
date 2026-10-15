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

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
  };
}
