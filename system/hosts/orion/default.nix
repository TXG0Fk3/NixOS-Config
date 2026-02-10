{ config, lib, pkgs, system-modules, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
    kernelPackages = pkgs.linuxPackages_zen;
    extraModulePackages = with config.boot.kernelPackages; [ rtw89-morrownr ];
    kernelModules = [ "rtw89_8852cu_git" "ntsync" ];
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
      wifi = {
        backend = "iwd";
        powersave = false;
        scanRandMacAddress = true;
        macAddress = "random";
      };
      ethernet.macAddress = "random";
    };
    firewall.enable = true;
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
    extraGroups = [ "wheel" "networkmanager" "podman" ];
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
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Services
  services = {
    fstrim.enable = true;
    tailscale.enable = false;
  };

  system.stateVersion = "25.11";
}
