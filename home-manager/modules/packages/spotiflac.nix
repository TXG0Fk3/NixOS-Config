{
  pkgs,
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "spotiflac";
  version = "7.1.2";

  src = fetchurl {
    url = "https://github.com/afkarxyz/SpotiFLAC/releases/download/v${version}/SpotiFLAC.AppImage";
    hash = "sha256-eOSlWchkeoPkyuNgmzjvrXIq4bqle/T3AcUKO/I4qoU=";
  };

  appImageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "SpotiFLAC";
    exec = "${pname} %U";
    icon = pname;
    comment = "Download Spotify tracks in FLAC from multiple sources";
    categories = [
      "Audio"
      "Network"
    ];
    terminal = false;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      ffmpeg
      webkitgtk_4_1
    ];

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/*.desktop \
      $out/share/applications/${pname}.desktop

    install -Dm444 \
      ${appImageContents}/usr/share/icons/hicolor/256x256/apps/${pname}.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  meta = with lib; {
    description = "Get Spotify tracks in true FLAC from Tidal, Qobuz & Amazon Music — no account required.";
    homepage = "https://github.com/afkarxyz/SpotiFLAC";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "spotiflac";
  };
}
