{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  rsync,
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
    rsync
  ];

  postPatch = ''
    substituteInPlace Build-Hatter.sh \
      --replace-fail 'gtk-update-icon-cache -f "$theme"' 'true'
  '';

  buildPhase = ''
    runHook preBuild

    bash ./Build-Hatter.sh <<< "1"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons"

    rm -rf Build/Hatter-kde*
    cp -a Build/Hatter* "$out/share/icons/"

    for theme in "$out/share/icons"/*/; do
      if [ -f "$theme/index.theme" ]; then
        gtk-update-icon-cache -f -q "$theme"
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
