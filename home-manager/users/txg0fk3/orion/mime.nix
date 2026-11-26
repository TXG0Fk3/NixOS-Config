{ lib, ... }:

let
  mkAssoc = desktop: types: lib.genAttrs types (_: desktop);
in
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications =
      mkAssoc "kitty.desktop" [
        "x-scheme-handler/terminal"
      ]
      // mkAssoc "librewolf.desktop" [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
        "text/html"
        "application/xhtml+xml"
      ]
      // mkAssoc "org.pwmt.zathura.desktop" [
        "application/pdf"
        "application/postscript"
        "image/vnd.djvu"
        "application/vnd.comicbook+zip"
        "application/vnd.comicbook-rar"
      ]
      // mkAssoc "Helix.desktop" [
        "text/plain"
        "text/markdown"
        "text/x-markdown"
        "text/csv"
        "text/tab-separated-values"
        "text/x-log"
        "text/xml"
        "application/xml"
        "application/json"
        "application/toml"
        "text/x-toml"
        "application/x-yaml"
        "text/yaml"
        "text/x-ini"
        "application/x-shellscript"
        "text/x-shellscript"
        "text/x-nix"
        "application/x-nix"
        "text/x-go"
        "text/x-csharp"
        "text/javascript"
        "application/javascript"
        "text/typescript"
        "application/typescript"
        "text/css"
        "text/x-lua"
        "text/x-python"
        "text/rust"
        "text/x-csrc"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-c++hdr"
        "text/x-makefile"
        "text/x-patch"
        "text/x-diff"
      ]
      // mkAssoc "org.gnome.Loupe.desktop" [
        "image/png"
        "image/jpeg"
        "image/webp"
        "image/gif"
        "image/avif"
        "image/heic"
        "image/jxl"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/vnd.microsoft.icon"
        "image/apng"
        "image/qoi"
      ]
      // mkAssoc "org.gnome.Showtime.desktop" [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/mpeg"
        "video/ogg"
        "video/x-flv"
        "video/x-m4v"
        "video/mp2t"
      ]
      // mkAssoc "com.github.neithern.g4music.desktop" [
        "audio/mpeg"
        "audio/mp4"
        "audio/flac"
        "audio/x-flac"
        "audio/ogg"
        "audio/x-vorbis+ogg"
        "audio/x-opus+ogg"
        "audio/wav"
        "audio/x-wav"
        "audio/webm"
        "audio/aac"
        "audio/x-aac"
        "audio/x-m4a"
        "audio/x-wavpack"
        "audio/x-ape"
      ]
      // mkAssoc "org.gnome.FileRoller.desktop" [
        "application/zip"
        "application/x-zip-compressed"
        "application/x-7z-compressed"
        "application/vnd.rar"
        "application/x-rar"
        "application/x-rar-compressed"
        "application/x-tar"
        "application/x-compressed-tar"
        "application/x-bzip-compressed-tar"
        "application/x-bzip2-compressed-tar"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
        "application/gzip"
        "application/x-gzip"
        "application/x-bzip2"
        "application/x-xz"
        "application/zstd"
        "application/x-cd-image"
      ]
      // mkAssoc "de.haeckerfelix.Fragments.desktop" [
        "application/x-bittorrent"
        "x-scheme-handler/magnet"
      ]
      // mkAssoc "md.obsidian.Obsidian.desktop" [
        "x-scheme-handler/obsidian"
      ];
  };
}
