{
  config,
  lib,
  pkgs,
  system-modules,
  ...
}:

{
  imports = [
    ./hardware.nix
    system-modules
    (system-modules + "/ui/xfce.nix")
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "rtw89_8852cu"
      "ntsync"
    ];
  };

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };

  # Network
  networking = {
    hostName = "Rigel";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
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
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # Users.
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
    ];
  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Flatpaks
  services.flatpak.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    # Virtualisation
    distrobox
  ];

  # Virtualisation
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  system.stateVersion = "26.05";
}
