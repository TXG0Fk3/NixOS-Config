self: super: {
  equibop = super.stdenv.mkDerivation {
    pname = "equibop";
    version = "3.1.2";

    src = super.fetchurl {
      url = "https://github.com/Equicord/Equibop/releases/download/v3.1.2/equibop-3.1.2.tar.gz";
      sha256 = "56fc219b801c65f4e9d715d89deac1e6f15a6951bd2a2307d9fec50a14afc131";
    };

    nativeBuildInputs = [ super.makeWrapper ];
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
