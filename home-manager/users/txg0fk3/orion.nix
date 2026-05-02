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
    (home-modules + "/flatpak.nix")
    (home-modules + "/bottles.nix")
    (home-modules + "/prismlauncher.nix")
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
    brain-sync = "cd ~/Brain && git add . && git commit -m \"🧠 Brain update: $(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main";
    usbmds = "sudo usb_modeswitch -v 0bda -p 1a2b -K";
  };

  # Overlays
  nixpkgs.overlays = [ (import (home-modules + "/overlays/equibop.nix")) ];

  # User Packages
  home.packages = with pkgs; [
    # Network & Streaming & Sharing
    firefox
    equibop
    telegram-desktop
    signal-desktop
    jellyfin-desktop
    localsend
    proton-vpn

    # Productivity / Knowledge
    (alpaca.override {
      ollama = pkgs.ollama-rocm;
    })
    gnome-feeds
    gnome-solanum
    logseq
    obsidian
    todoist-electron

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
    mousai
    parabolic
    showtime
    (callPackage (home-modules + "/packages/spotiflac.nix") { })

    # System Tools
    impression
    baobab
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
    (callPackage (home-modules + "/packages/hatter-icon-theme.nix") { })

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

  # Services
  services = {
    syncthing.enable = true;
  };

  # Themes
  gtk = {
    enable = true;
    iconTheme.name = "Hatter-Blue";
    theme.name = "adw-gtk3-dark";
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };
}
