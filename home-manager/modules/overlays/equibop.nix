self: super: {
  equibop = super.stdenv.mkDerivation {
    pname = "equibop";
    version = "3.1.3";

    src = super.fetchurl {
      url = "https://github.com/Equicord/Equibop/releases/download/v3.1.3/equibop-3.1.3.tar.gz";
      sha256 = "06e79bd76d52787ea2e5e3bee17a61f9f83872f8c4b541f23c50ab4d80fdfb32";
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
