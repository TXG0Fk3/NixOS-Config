{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Tmpfs
  boot.tmp.useTmpfs = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Network
  networking.hostName = "TXGNixOS";
  networking.networkmanager.enable = true;

  # Time Zone.
  time.timeZone = "America/Maceio";

  # Internationalisation
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2";

  # Configure keymap in X11
  services.xserver.xkb.layout = "br";

  # UI
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Root
  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };

  # Users.
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # System Packages.
  environment.systemPackages = with pkgs; [
    gnome-system-monitor
    gnome-disk-utility

    vim
    btop
    fastfetch
    wget
  ];

  programs = {
    # Browser
    firefox = {
      enable = true;
      languagePacks = ["pt-BR"];
    };

    nano.enable = false;
  };

  # Services
    # Preload
    services.preload.enable = true;
    
    # OpenSSH.
    services.openssh.enable = false;

    # Firewall
    networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
