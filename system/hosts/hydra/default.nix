{ config, pkgs, system-modules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    system-modules
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
    size = 8*1024;
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
      allowedTCPPorts = [ 22 80 443 8443 ];
      allowedUDPPorts = [ 19132 ];
      allowedTCPPortRanges = [
        { from = 25500; to = 25600; }
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
    superfile
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
  };

  system.stateVersion = "25.05";
}