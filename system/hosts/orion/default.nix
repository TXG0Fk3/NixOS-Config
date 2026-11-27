{
  inputs,
  lib,
  pkgs,
  system-modules,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./mounts.nix
    ./overlays.nix
    ./systemd.nix
    system-modules
    (system-modules + "/gaming.nix")
    (system-modules + "/keyd.nix")
    (system-modules + "/ui/hypr.nix")
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.artcraft.nixosModules.default
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      timeout = 3;
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 5;
      pkiBundle = "/var/lib/sbctl";
    };
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_betelgeuse;
    kernelModules = [
      "rtw89_8852cu"
      "ntsync"
      "tcp_bbr"
      "bfq"
    ];
    kernel.sysctl = {
      # Memory & ZRAM
      "vm.page-cluster" = 0;
      "vm.swappiness" = 150;
      "vm.vfs_cache_pressure" = 50;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;

      # Storage writeback
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_bytes" = 268435456;

      # Network
      "net.core.default_qdisc" = "fq";
      "net.core.netdev_max_backlog" = 4096;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_wmem" = "4096 16384 16777216";

      # Kernel
      "kernel.nmi_watchdog" = 0;
    };
    extraModprobeConfig = ''
      options rtw89_core disable_ps_mode=y
    '';
  };

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };

  # Network
  networking = {
    hostName = "Orion";
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
      settings.main.systemd-resolved = false;
      wifi = {
        backend = "iwd";
        powersave = false;
        scanRandMacAddress = true;
        macAddress = "random";
      };
      ethernet.macAddress = "random";
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        53317 # LocalSend
      ];
      allowedUDPPorts = [
        53317 # LocalSend
      ];
    };
  };

  # Hardware
  hardware = {
    usb-modeswitch.enable = true;
    amdgpu.overdrive.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # Users
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "gamemode"
    ];
  };

  # Flatpaks
  services.flatpak.enable = true;

  # Environment & Packages
  environment = {
    sessionVariables = {
      AMD_VULKAN_ICD = "RADV";
      MESA_SHADER_CACHE_MAX_SIZE = "12G";
    };
    systemPackages = with pkgs; [
      # Virtualisation
      distrobox

      # Other
      sbctl
    ];
  };

  # Virt-Manager
  programs.virt-manager.enable = true;

  # ArtCraft
  programs.artcraft = {
    enable = true;
    apps = [
      "photocraft"
      "filmcraft"
      "figcraft"
    ];
  };

  # GPU Screen Recorder
  programs.gpu-screen-recorder = {
    enable = true;
    ui.enable = true;
  };

  # KDE Connect
  programs.kdeconnect.enable = true;

  # GameMode (RX 6600 on /sys/class/drm/card1)
  programs.gamemode.settings.gpu = {
    apply_gpu_optimisations = "accept-responsibility";
    gpu_device = 1;
    amd_performance_level = "high";
  };

  # Virtualisation
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.swtpm.enable = true;
    };
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Services
  services = {
    lact.enable = true;
    tailscale.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  system.stateVersion = "26.05";
}
