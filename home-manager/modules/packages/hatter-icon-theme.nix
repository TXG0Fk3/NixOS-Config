{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hatter-icon-theme";
  version = "2026-09-12";

  src = fetchFromGitHub {
    owner = "Mibea";
    repo = "Hatter";
    rev = "e2be38b856d55bfa578a51c5c7c36c41528982e9";
    hash = "sha256-EQMsEjUxv9wyIWg6k/rc4FvhPBqq820Y/MgeG5KytVQ=";
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
