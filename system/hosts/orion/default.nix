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
    ./overlays.nix
    ./mounts.nix
    system-modules
    (system-modules + "/ui/gnome.nix")
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_betelgeuse;
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
    hostName = "Orion";
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
      "podman"
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
    gnome-boxes
    virt-manager
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

  # Services
  services = {
    tailscale.enable = true;
  };

  system.stateVersion = "25.11";
}
