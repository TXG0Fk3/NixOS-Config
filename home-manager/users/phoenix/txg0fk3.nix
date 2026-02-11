{
  config,
  pkgs,
  home-modules,
  ...
}:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

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
    '';
  };
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "catppuccin_mocha";
  };

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
