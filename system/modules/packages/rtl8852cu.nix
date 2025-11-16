{ lib, stdenv, fetchFromGitHub, kernel, bc, nukeReferences }:

stdenv.mkDerivation {
  pname = "rtl8852cu-morrownr";
  version = "${kernel.version}-20240510";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtl8852cu-20240510";
    rev = "c01bd409ddce75822cd9127ac1a97ba4fd31a9d8";
    hash = "sha256-yp5e2ijkqKji+dJ+XPMJJPhkjh5NYUiFEncQc4HdNEA=";
  };

  nativeBuildInputs = [ bc nukeReferences ] ++ kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

   prePatch = ''
    substituteInPlace Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace /sbin/depmod \# \
      --replace '/etc/modprobe.d' "$out/etc/modprobe.d" \
      --replace 'sh edit-options.sh' 'true'
  '';

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "MODDESTDIR=$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/"
  ];

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/
    nuke-refs $out/lib/modules/*/kernel/drivers/net/wireless/*.ko
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Realtek RTL8852CU WiFi driver (morrownr fork)";
    homepage = "https://github.com/morrownr/rtl8852cu-20240510";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}