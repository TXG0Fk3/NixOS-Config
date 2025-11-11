{ config, pkgs, inputs, ... }:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Gnome Stuff
    gnome-text-editor
    baobab
    decibels
    loupe
    showtime

    # Network
    microsoft-edge
    equibop
    spotify
      
    # Gaming && Wine
    steam
    steam-run
    bottles

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
}