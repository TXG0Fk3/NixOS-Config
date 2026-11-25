{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./starship.nix
    ./zsh.nix
    ./fastfetch.nix
  ];

  # Nix
  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Bootloader
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;

  # Logs
  services.journald.settings.Journal.SystemMaxUse = "500M";

  # Locale and TimeZone
  time.timeZone = "America/Maceio";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us-acentos";

  # Root
  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };

  # Network
  networking = {
    modemmanager.enable = lib.mkForce false;
    nameservers = lib.mkDefault [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];
  };
  services.resolved = {
    enable = lib.mkDefault true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = [ "~." ];
      FallbackDNS = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
      DNSOverTLS = "true";
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # SystemPackages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    helix
    btop
    wget
    cryptsetup
  ];

  programs = {
    nano.enable = false;
    nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 7d --keep 5";
      };
    };
  };
}
