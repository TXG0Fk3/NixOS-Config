{ config, pkgs, home-modules, ... }:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  # Overlays
  nixpkgs.overlays = [ (import (home-modules + "/overlays/equibop.nix")) ];

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char
      
      fastfetch -c minimal
    '';
  };
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "catppuccin_mocha";
  };

  # User Packages
  home.packages = with pkgs; [
    # Network & Streaming & Sharing
    firefox
    equibop
    localsend

    # Productivity / Knowledge
    gnome-feeds
    planify
    obsidian
    gnome-solanum

    # Media & Utilities
    gnome-text-editor
    decibels
    eyedropper
    fragments
    gradia
    loupe
    parabolic
    showtime

    # System Tools
    impression
    baobab
    deja-dup

    # Content Creation
    obs-studio
    shotcut
      
    # Gaming && Wine
    steam
    steam-run
    protonplus
    gamescope
    lsfg-vk
    lsfg-vk-ui
    mangohud

    # Remote Access
    remmina

    # Development
    git
    vscode
    gnome-builder
    python312
    python312Packages.pygobject3
    
    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono

    # Icon Packs
    morewaita-icon-theme

    # Themes
    marble-shell-theme
    adw-gtk3
  ];

  imports = [
    (home-modules + "/bottles.nix")
    (home-modules + "/flatpak.nix")
    (home-modules + "/prismlauncher.nix")
    (home-modules + /spotify.nix)
  ];

  # Themes
  gtk = {
    enable = true;
    iconTheme.name = "MoreWaita";
    theme.name = "adw-gtk3-dark";
  };
}