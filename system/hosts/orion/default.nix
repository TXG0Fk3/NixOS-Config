{
  inputs,
  config,
  lib,
  pkgs,
  system-modules,
  ...
}:

let
  mangohudConfig = lib.concatStringsSep "," [
    "no_display"
    "output_folder=~/.cache/mangohud"
    "log_interval=1000"
    "autostart_log=1"
  ];
in
{
  imports = [
    ./hardware.nix
    ./mounts.nix
    ./overlays.nix
    ./systemd.nix
    system-modules
    (system-modules + "/ui/hypr.nix")
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.artcraft.nixosModules.default
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
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
    virt-manager

    # Gaming & Performance
    mangohud

    # Other
    sbctl
  ];

  # ArtCraft
  programs.artcraft = {
    enable = true;
    apps = [
      "photocraft"
      "filmcraft"
    ];
  };

  # Gaming
  # MangoHud is configured through MANGOHUD_CONFIG (an environment variable) instead of
  # a config file, because Steam games run inside the pressure-vessel container, which
  # does not see the host's /etc. Logs go to ~/.cache because the container also does not
  # share the whole /run/user/$UID, while $HOME is shared.
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
        MANGOHUD_CONFIG = mangohudConfig;
      };
    };
    extraPackages = with pkgs; [
      mangohud
    ];
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # MangoHud
  environment.sessionVariables.MANGOHUD_CONFIG = mangohudConfig;

  # GPU Screen Recorder
  programs.gpu-screen-recorder = {
    enable = true;
    ui.enable = true;
  };

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
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Services
  services = {
    tailscale.enable = true;
  };

  system.stateVersion = "26.05";
}
