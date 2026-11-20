{ lib, cachyosKernels }:

let
  base = cachyosKernels.linux-cachyos-latest;
in
base.override {
  lto = "thin";
  cpusched = "bore";
  processorOpt = "x86_64-v3";
  bbr3 = true;

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

      # Unused Intel & non-AMDGPU drivers (Orion is AMD Ryzen + RX 6600)
      DRM_I915 = no;
      DRM_XE = no;
      DRM_NOUVEAU = no;
      DRM_RADEON = no;
      DRM_VMWGFX = no;
      DRM_GMA500 = no;
      DRM_ACCEL = no;
      INTEL_IOMMU = no;
      X86_INTEL_PSTATE = no;
      KVM_INTEL = no;

      # Unused guest hypervisors
      XEN = no;
      HYPERV = no;

      # Heavy server / industrial / embedded / TV subsystems not used on desktop
      INFINIBAND = no;
      IIO = no;
      COMEDI = no;
      STAGING = no;
      MTD = no;
      CAN = no;
      NET_DSA = no;
      WWAN = no;
      IEEE802154 = no;
      MEDIA_DIGITAL_TV_SUPPORT = no;
      MEDIA_ANALOG_TV_SUPPORT = no;
      MEDIA_RADIO_SUPPORT = no;
    }
  );
}
