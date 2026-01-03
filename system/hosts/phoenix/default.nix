{ config, lib, pkgs, system-modules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    system-modules
    (system-modules + "/ui/gnome.nix")
  ];
  
  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Swap
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "lz4";
  };

  # Network
  networking = {
    hostName = "Phoenix";
    firewall.enable = true;
  };

  # Hardware
  hardware = {
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
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Flatpaks
  services.flatpak.enable = true;

  system.stateVersion = "25.11";
}
