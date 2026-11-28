{
  lib,
  mesa,
}:

let
  base = mesa.override {
    galliumDrivers = [
      "radeonsi"
      "llvmpipe"
    ];
    vulkanDrivers = [ "amd" ];
    vulkanLayers = [
      "device-select"
      "overlay"
      "vram-report-limit"
    ];
    enablePatentEncumberedCodecs = true;
    withValgrind = false;
  };

  dropFlag = prefix: flags: builtins.filter (f: !(lib.hasPrefix prefix f)) flags;
in
base.overrideAttrs (old: {
  pname = "mesa-rigel";

  outputs = [ "out" ];

  mesonFlags =
    (lib.pipe old.mesonFlags [
      (dropFlag "-Dteflon=")
      (dropFlag "-Damdgpu-virtio=")
      (dropFlag "-Dgallium-rusticl=")
      (dropFlag "-Dgallium-rusticl-enable-drivers=")
      (dropFlag "-Dintel-rt=")
      (dropFlag "-Dtools=")
      (dropFlag "-Dinstall-mesa-clc=")
      (dropFlag "-Dinstall-precomp-compiler=")
    ])
    ++ [
      (lib.mesonBool "teflon" false)
      (lib.mesonBool "amdgpu-virtio" false)
      (lib.mesonBool "gallium-rusticl" false)
      (lib.mesonEnable "intel-rt" false)
      (lib.mesonBool "install-mesa-clc" false)
      (lib.mesonBool "install-precomp-compiler" false)
      (lib.mesonOption "optimization" "3")
    ];

  env = (old.env or { }) // {
    NIX_CFLAGS_COMPILE = toString [
      (old.env.NIX_CFLAGS_COMPILE or "")
      "-march=znver3"
      "-mtune=znver3"
    ];
  };

  postInstall = "";

  postFixup = builtins.replaceStrings [ " $opencl/lib/libRusticlOpenCL.so" ] [ "" ] old.postFixup;
})
