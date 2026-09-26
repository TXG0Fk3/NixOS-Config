final: prev: {
  equibop = prev.stdenv.mkDerivation rec {
    pname = "equibop";
    version = "3.3.1";

    src = prev.fetchurl {
      url = "https://github.com/Equicord/Equibop/releases/download/v${version}/equibop-${version}.tar.gz";
      sha256 = "ecba2f8f4546697b055b35e5b94ecaf055c723c18a0f452405684b228fbfd402";
    };

    nativeBuildInputs = [
      prev.makeWrapper
      prev.autoPatchelfHook
      prev.copyDesktopItems
    ];

    buildInputs = [
      prev.electron
      prev.pipewire
      prev.libpulseaudio
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/equibop
      cp -r resources $out/opt/equibop

      makeWrapper ${prev.electron}/bin/electron $out/bin/equibop \
        --add-flags "$out/opt/equibop/resources/app.asar" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags "--enable-features=WaylandWindowDecorations" \
        --add-flags "--enable-wayland-ime" \
        --set-default MOZ_ENABLE_WAYLAND 1

      runHook postInstall
    '';

    desktopItems = [
      (prev.makeDesktopItem {
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

    meta = with prev.lib; {
      description = "Equibop - A custom Discord client";
      homepage = "https://github.com/Equicord/Equibop";
      license = licenses.gpl3Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "equibop";
    };
  };
}
