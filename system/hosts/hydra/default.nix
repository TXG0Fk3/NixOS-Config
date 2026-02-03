{ config, pkgs, system-modules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
    system-modules
    (system-modulse + "/containers/qbittorrent.nix")
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    }; 
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = { "vm.swappiness" = 10; };
  };

  # Swap
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 12*1024;
  }];
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "lz4";
    priority = 100;
  };

  # Network
  networking = {
    hostName = "Hydra";
    firewall = {
      enable =  true;
      allowedTCPPorts = [ 
        22   # SSH
        8443 # Crafty
        8096 # Jellyfin
      ];
      allowedUDPPorts = [
        19132 # MCBE Server
        5520  # Hyale Server
      ];
      allowedTCPPortRanges = [
        { from = 25500; to = 25600; } # Mine Java
      ];
    };
  };

  # Users.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "podman" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Tools
    git
    curl
    zellij
    superfile

    # JRE
    javaPackages.compiler.temurin-bin.jre-25

    # Containers
    podman-compose
  ];

  # Containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Services
  services = {
    openssh.enable = true;
    fail2ban.enable = true;

    homelab = {
      qbittorrent = {
        enable = true;
        user = "admin";
        storagePath = "/mnt/storage/downloads";
      };
    };
  };

  system.stateVersion = "25.11";
}