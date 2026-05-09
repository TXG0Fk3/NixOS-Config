{
  pkgs,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  lib,
  ...
}@args:

let
  linuxBetelgeuse = buildLinux (
    args
    // rec {
      version = "7.0.5";
      modDirVersion = "${version}-Betelgeuse";
      stdenv = pkgs.impureUseNativeOptimizations pkgs.llvmPackages_22.stdenv;
      isZen = true;
      extraMakeFlags = [
        "LLVM=1"
        "LLVM_IAS=1"
      ];

      mm = lib.versions.majorMinor version;

      src = builtins.fetchurl {
        url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
        sha256 = "0g5c732144ig8rk2nrlsbwdh88q5ghi3n1n6c3y9jlv7q6hv0pwn";
      };

      linuxTkgPatchesRepo = fetchFromGitHub {
        owner = "Frogging-Family";
        repo = "linux-tkg";
        rev = "3954fc8046ad8d4c838865fe1085d7cf27477fd2";
        hash = "sha256-MW0qx24+AJkFPD5nz3fDK/AXK5f1QH2TN/npsV0YkHg=";
      };

      linuxTkgPatches = [
        "0002-clear-patches"
        "0003-glitched-base"
        "0001-bore"
        "0003-glitched-cfs"
        "0006-add-acs-overrides_iommu"
        "0012-misc-additions"
        "0013-optimize_harder_O3"
      ];

      kernelPatches = builtins.map (patchName: {
        inherit patchName;
        patch = "${linuxTkgPatchesRepo}/linux-tkg-patches/${mm}/${patchName}.patch";
      }) linuxTkgPatches;

      structuredExtraConfig =
        with lib.kernel;
        builtins.mapAttrs (_: value: lib.mkForce value) {
          LOCALVERSION = freeform "-Betelgeuse";
          ZENIFY = yes;
          WINESYNC = module;

          # TKG Defaults
          DYNAMIC_FAULT = no;
          DEFAULT_FQ_CODEL = no;
          WERROR = no;
          NTP_PPS = no;
          ZSWAP_COMPRESSOR_DEFAULT_LZO = no;
          PROFILE_ALL_BRANCHES = no;
          CRYPTO_LZ4 = yes;
          CRYPTO_LZ4HC = yes;
          LZ4_COMPRESS = yes;
          LZ4HC_COMPRESS = yes;
          ZSWAP_COMPRESSOR_DEFAULT_LZ4 = yes;
          DEBUG_FORCE_FUNCTION_ALIGN_64B = no;
          X86_P6_NOP = no;
          RCU_STRICT_GRACE_PERIOD = no;
          ZSWAP_COMPRESSOR_DEFAULT = freeform "lz4";
          CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = yes;
          CPU_FREQ_DEFAULT_GOV_ONDEMAND = no;
          CPU_FREQ_DEFAULT_GOV_CONSERVATIVE = no;
          CPU_FREQ_DEFAULT_GOV_PERFORMANCE = no;
          CPU_FREQ_DEFAULT_GOV_PERFORMANCE_NODEF = no;
          BLK_DEV_LOOP = module;

          # Clang/LLVM
          LTO_CLANG_FULL = yes;
          LTO_CLANG_THIN = no;
          LTO_NONE = no;
          KCSAN = no;
          INIT_ON_FREE_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;
          INIT_STACK_NONE = no;

          # Hardware
          X86_NATIVE_CPU = yes;
          GENERIC_CPU = no;

          # BORE
          SCHED_BORE = yes;
          MIN_BASE_SLICE_NS = freeform "2000000";

          # Tickless Timers
          HZ_PERIODIC = no;
          NO_HZ = yes;
          NO_HZ_COMMON = yes;
          NO_HZ_FULL = yes;
          NO_HZ_FULL_NODEF = yes;
          NO_HZ_IDLE = no;
          TICK_CPU_ACCOUNTING = no;
          VIRT_CPU_ACCOUNTING_GEN = yes;
          CONTEXT_TRACKING = yes;
          CONTEXT_TRACKING_FORCE = no;
          HZ_1000 = yes;
          HZ_1000_NODEF = yes;

          # Preempt
          PREEMPT = yes;
          PREEMPT_COUNT = yes;
          PREEMPT_VOLUNTARY = no;
          PREEMPTION = yes;
          PREEMPT_DYNAMIC = yes;

          # Disable NUMA / FTrace / Debug
          NUMA = no;
          AMD_NUMA = no;
          ACPI_NUMA = no;
          X86_64_ACPI_NUMA = no;
          NODES_SPAN_OTHER_NODES = no;
          NUMA_EMU = no;
          NODES_SHIFT = no;
          NEED_MULTIPLE_NODES = no;
          USE_PERCPU_NUMA_NODE_ID = no;
          FUNCTION_TRACER = no;
          FUNCTION_GRAPH_TRACER = no;
          SLUB_DEBUG = no;
          PM_DEBUG = no;
          PM_ADVANCED_DEBUG = no;
          PM_SLEEP_DEBUG = no;
          ACPI_DEBUG = no;
          SCHED_DEBUG = no;
          LATENCYTOP = no;
          DEBUG_PREEMPT = no;

          # Disable NVIDIA and Intel
          NVIDIA = no;
          NVIDIA_DRM = no;
          NVIDIA_UVM = no;
          I915 = no;
          DRM_I915 = no;
          INTEL_IOMMU = no;
          INTEL_PSTATE = no;
        };
      ignoreConfigErrors = true;
    }
    // (args.argsOverride or { })
  );
in
linuxBetelgeuse.overrideAttrs (old: {
  passthru = linuxBetelgeuse.passthru;
  hardeningDisable = (old.hardeningDisable or [ ]) ++ [ "strictoverflow" ];
})
