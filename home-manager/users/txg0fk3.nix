{ config, pkgs, home-modules, ... }:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  # Overlays
  nixpkgs.overlays = [ (import (home-modules + "/overlays/equibop.nix")) ];

  # User Packages
  home.packages = with pkgs; [
    # Gnome Stuff
    gnome-text-editor
    baobab
    decibels
    loupe
    showtime

    # Network
    firefox
    equibop
    localsend

    # Utils
    parabolic

    # Content Creation
    obs-studio
    shotcut
      
    # Gaming && Wine
    steam
    steam-run
    protonplus
    mangohud

    # Remote Access
    remmina

    # Development
    git
    vscode

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono

    # Ricing
    morewaita-icon-theme
    adw-gtk3
  ];

  imports = [
    (home-modules + "/flatpak.nix")
    (home-modules + "/spotify.nix")
    (home-modules + "/prismlauncher.nix")
    (home-modules + "/bottles.nix")
  ];
}