{
  config,
  pkgs,
  home-modules,
  ...
}:

{
  imports = [
    ./common.nix
    (home-modules + "/flatpak.nix")
  ];

  # User Packages
  home.packages = with pkgs; [
    # Network
    firefox

    # Media & Utilities
    gnome-calculator
    gnome-text-editor
    decibels
    loupe
    showtime

    # System Tools
    baobab

    # Development
    git

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono

    # Themes
    adw-gtk3
    adwaita-qt
    adwaita-qt6
  ];

  # Themes
  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };
}
