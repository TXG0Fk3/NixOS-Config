{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hatter-icon-theme";
  version = "2026-03-27";

  src = fetchFromGitHub {
    owner = "Mibea";
    repo = "Hatter";
    rev = "a16a14793e726060dfbf3eb9885fa58d2ef1607d";
    hash = "sha256-Hil010yrHBMzjkvFEt7if6zwBEf/XrRnqEwk6QVSN9U=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"

    cp -r Hatter* "$out/share/icons/" 2>/dev/null || true

    rm -rf "$out/share/icons/Hatter-kde"*
    rm -rf "$out/share/icons/Hatter-kde-light"
    rm -rf "$out/share/icons/Hatter-kde-dark"

    for theme in "$out/share/icons"/*/; do
      if [ -d "$theme" ]; then
        gtk-update-icon-cache -f -q "$theme" || true
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Icon theme/desktop theme with the right balance between unity and diversity.";
    homepage = "https://github.com/Mibea/Hatter";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
  };
})
