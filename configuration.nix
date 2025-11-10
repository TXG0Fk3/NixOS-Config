{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
    hostName = "TXGNixOS";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Time Zone.
  time.timeZone = "America/Maceio";

  # Internationalisation
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2";

  # Configure keymap in X11
  services.xserver.xkb.layout = "br";

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # UI
  services = {
    xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    gnome.core-apps.enable = false;
  };
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  # Sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
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
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      gnome-text-editor
      baobab
      decibels
      loupe
      showtime

      microsoft-edge
      equibop

      morewaita-icon-theme
    ];
  };

  # Flatpaks
  services.flatpak.enable = true;

  # System Packages.
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnomeExtensions.logo-menu
    gnomeExtensions.space-bar
    gnomeExtensions.appindicator
    gnomeExtensions.window-title-is-back
    gnomeExtensions.rounded-window-corners-reborn
    
    gnome-console
    gnome-disk-utility
    gnome-tweaks
    mission-center
    nautilus

    vim
    btop
    fastfetch
    wget
  ];

  programs = {
    nano.enable = false;
  };

  # Services
  services = {
    preload.enable = true;
    openssh.enable = false;
  };

  system.stateVersion = "25.05";
}
