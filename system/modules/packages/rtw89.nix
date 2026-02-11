{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  bc,
  nukeReferences,
}:

stdenv.mkDerivation {
  pname = "rtw89-morrownr";
  version = "${kernel.version}";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtw89";
    rev = "master";
    hash = "sha256-UoiiyiOtU12FzWx7KqWEiTbulHRBbhT7bd7L97NniHo=";
  };

  nativeBuildInputs = [
    bc
    nukeReferences
  ]
  ++ kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/"
  '';

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89
    nuke-refs $out/lib/modules/*/kernel/drivers/net/wireless/realtek/rtw89/*.ko
  '';

  meta = with lib; {
    description = "Realtek rtw89 WiFi driver with USB support (morrownr fork)";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
