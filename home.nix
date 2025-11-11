{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

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
      
    # Gaming && Wine
    steam
    steam-run
    prismlauncher
    bottles
    protonplus
    mangohud

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

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
    ];
  };
}