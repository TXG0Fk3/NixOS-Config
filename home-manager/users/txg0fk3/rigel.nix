{
  config,
  pkgs,
  inputs,
  secrets,
  home-modules,
  ...
}:

{
  imports = [
    ./common.nix
    (home-modules + "/bottles.nix")
    (home-modules + "/flatpak.nix")
    (home-modules + "/vscodium.nix")
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Sops
  sops = {
    defaultSopsFile = (secrets + "/common.yaml");
    age.keyFile = "/home/TXG0Fk3/.config/sops/age/keys.txt";

    secrets = {
      "git/userName" = { };
      "git/userEmail" = { };
    };

    templates."git-secrets" = {
      content = ''
        [user]
          name = ${config.sops.placeholder."git/userName"}
          email = ${config.sops.placeholder."git/userEmail"}
      '';
    };
  };

  # Shell Aliases
  programs.zsh.shellAliases = {
    usbmds = "sudo usb_modeswitch -v 0bda -p 1a2b -K";
  };

  # Overlays
  nixpkgs.overlays = [ (import (home-modules + "/overlays/equibop.nix")) ];

  # User Packages
  home.packages = with pkgs; [
    # Network & Streaming & Sharing
    firefox
    equibop
    localsend
    proton-vpn

    # Media & Utilities
    gnome-calculator
    gnome-text-editor
    decibels
    file-roller
    fragments
    gradia
    loupe
    showtime

    # System Tools
    impression
    baobab
    usb-modeswitch

    # Content Creation
    obs-studio

    # Gaming && Wine
    steam
    steam-run
    protonplus
    gamescope
    lsfg-vk
    lsfg-vk-ui
    mangohud

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono

    # Icon Packs
    (callPackage (home-modules + "/packages/hatter-icon-theme.nix") { })
  ];

  # Flatpaks
  services.flatpak.packages = [
    "io.github.vikdevelop.SaveDesktop"
    "io.mrarm.mcpelauncher"
    "org.vinegarhq.Sober"
  ];

  # Git
  programs.git = {
    enable = true;
    includes = [ { path = config.sops.templates."git-secrets".path; } ];
  };
}
