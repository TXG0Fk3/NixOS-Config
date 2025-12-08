self: super: {
  equibop = super.stdenv.mkDerivation {
    pname = "equibop";
    version = "3.1.4";

    src = super.fetchurl {
      url = "https://github.com/Equicord/Equibop/releases/download/v3.1.4/equibop-3.1.4.tar.gz";
      sha256 = "bdfca42a21633759541449678c90cb6fee7e4a2e256e06c61d94933a630a145a";
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
