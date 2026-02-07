self: super: {
  equibop = super.stdenv.mkDerivation rec {
    pname = "equibop";
    version = "3.1.8";

    src = super.fetchurl {
      url = "https://github.com/Equicord/Equibop/releases/download/v${version}/equibop-${version}.tar.gz";
      sha256 = "58b91351b9c3044ada50e93ee47a57c2edfa5a48c90527e7a6370dc2387e81eb";
    };

    nativeBuildInputs = [ super.makeWrapper super.autoPatchelfHook ];
    buildInputs = [
      super.electron
      super.pipewire
      super.libpulseaudio
      (super.lib.getLib super.stdenv.cc.cc)
    ];

    installPhase = ''
      mkdir -p $out/opt/equibop
      cp -r resources $out/opt/equibop

      makeWrapper ${super.electron}/bin/electron $out/bin/equibop \
        --add-flags "$out/opt/equibop/resources/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

      mkdir -p $out/share/applications
      cat > $out/share/applications/equibop.desktop <<EOF
[Desktop Entry]
Name=Discord
Exec=equibop %U
Terminal=false
Type=Application
Icon=discord
Categories=Utility;
EOF
    '';
  };
}
