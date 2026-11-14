{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "hatter-icon-theme";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "Mibea";
    repo = "Hatter";
    rev = "V4.0";
    hash = "sha256-eEoa24v9gJ/Ka4MwMmetua9o/S33nq+P2mOcSb1gN6o=";
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

  meta = {
    description = "Icon theme/desktop theme with the right balance between unity and diversity.";
    homepage = "https://github.com/Mibea/Hatter";
    license = [ lib.licenses.gpl3Only ];
    platforms = lib.platforms.linux;
  };
})
