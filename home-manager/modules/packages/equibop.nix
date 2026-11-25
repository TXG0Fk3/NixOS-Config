{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  electron,
  pipewire,
  libpulseaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "equibop";
  version = "3.3.4";

  src = fetchurl {
    url = "https://github.com/Equicord/Equibop/releases/download/v${finalAttrs.version}/equibop-${finalAttrs.version}.tar.gz";
    sha256 = "66ed6675185db9a7130eedf00b224e923f2dffd11eaa20708942c0b9e03ed9dd";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    electron
    pipewire
    libpulseaudio
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/equibop
    cp -r resources $out/opt/equibop

    makeWrapper ${electron}/bin/electron $out/bin/equibop \
      --add-flags "$out/opt/equibop/resources/app.asar" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations" \
      --add-flags "--enable-wayland-ime" \
      --set-default MOZ_ENABLE_WAYLAND 1

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Equibop";
      desktopName = "Equibop";
      exec = "equibop %U";
      icon = "discord";
      startupWMClass = "equibop";
      genericName = "Internet Messenger";
      keywords = [
        "discord"
        "equibop"
        "chat"
      ];
      categories = [
        "Network"
        "InstantMessaging"
        "Chat"
      ];
    })
  ];

  meta = {
    description = "Equibop - A custom Discord client";
    homepage = "https://github.com/Equicord/Equibop";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "equibop";
  };
})
