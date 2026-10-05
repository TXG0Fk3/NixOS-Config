{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nautilus
    ffmpegthumbnailer
    gdk-pixbuf
    libheif
    webp-pixbuf-loader
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
  };
}
