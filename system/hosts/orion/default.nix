{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
    ../../modules
    ../../modules/ui/gnome.nix
  ];
  
  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    }; 
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

  # Network
  networking = {
    hostName = "Orion";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
    extraGroups = [ "wheel" "networkmanager" ];
  };

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
    preload.enable = true;
    openssh.enable = false;
  };

  system.stateVersion = "25.05";
}
