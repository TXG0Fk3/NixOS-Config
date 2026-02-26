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

  imports = [
    ./sops.nix
    (home-modules + "/flatpak.nix")
    (home-modules + "/bottles.nix")
    (home-modules + "/prismlauncher.nix")
    (home-modules + "/vscodium.nix")
  ];

  # Overlays
  nixpkgs.overlays = [ (import (home-modules + "/overlays/equibop.nix")) ];

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    initContent = ''
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char

      fastfetch -c minimal
    '';
    shellAliases = {
      brain-sync = "cd ~/Brain && git add . && git commit -m \"🧠 Brain update: $(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main";
    };
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
    telegram-desktop
    jellyfin-desktop
    localsend
    protonvpn-gui

    # Productivity / Knowledge
    gnome-feeds
    gnome-solanum
    logseq
    obsidian
    planify

    # Media & Utilities
    gnome-calculator
    gnome-podcasts
    gnome-text-editor
    decibels
    eartag
    eyedropper
    file-roller
    fragments
    gapless
    gradia
    loupe
    parabolic
    showtime

    # System Tools
    impression
    baobab
    deja-dup
    usb-modeswitch
    cryptomator

    # Content Creation
    obs-studio
    shotcut

    # Gaming && Wine
    steam
    steam-run
    openmw
    protonplus
    gamescope
    lsfg-vk
    lsfg-vk-ui
    mangohud

    # Remote Access
    remmina

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
    adwaita-qt
    adwaita-qt6
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

  # Themes
  gtk = {
    enable = true;
    iconTheme.name = "MoreWaita";
    theme.name = "adw-gtk3-dark";
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };
}
