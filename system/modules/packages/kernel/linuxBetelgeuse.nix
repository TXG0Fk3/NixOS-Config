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

      DRM_I915 = no;
      INTEL_IOMMU = no;
      X86_INTEL_PSTATE = no;
    }
  );
}
