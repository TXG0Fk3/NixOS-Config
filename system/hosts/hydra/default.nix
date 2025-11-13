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
  };

  # Network
  networking = {
    hostName = "Hydra";
    firewall = {
      enable =  true;
      allowedTCPPorts = [ 22 80 443 ];
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