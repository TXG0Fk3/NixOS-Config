{ lib, cachyosKernels }:

let
  base = cachyosKernels.linux-cachyos-latest;
in
base.override {
  lto = "thin";
  cpusched = "bore";
  processorOpt = "x86_64-v3";

  modDirVersion = "${lib.versions.pad 3 base.version}-Betelgeuse";

  structuredExtraConfig = lib.mapAttrs (_: lib.mkForce) (
    with lib.kernel;
    {
      LOCALVERSION = freeform "-Betelgeuse";
      CGROUP_DMEM = yes;

      # Workaround: thin LTO + Rust breaks BTF with pahole 1.32
      # https://github.com/xddxdd/nix-cachyos-kernel/issues/115
      RUST = no;
      DRM_PANIC_SCREEN_QR_CODE = no;

      DRM_I915 = no;
      INTEL_IOMMU = no;
      X86_INTEL_PSTATE = no;
    }
  );
}
