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

  # UI
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

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
  services = {
    preload.enable = true;
    openssh.enable = false;
  };

  system.stateVersion = "25.05";
}
