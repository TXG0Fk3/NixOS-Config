{
  config,
  pkgs,
  inputs,
  secrets,
  home-modules,
  users,
  ...
}:

{
  imports = [
    (users + "/txg0fk3/common.nix")
    (home-modules + "/hypr")
    (home-modules + "/bottles.nix")
    (home-modules + "/fastfetch.nix")
    (home-modules + "/flatpak.nix")
    (home-modules + "/prismlauncher.nix")
    (home-modules + "/vscodium.nix")
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Sops
  sops = {
    defaultSopsFile = (secrets + "/common.yaml");
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

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
    localsend
    proton-vpn
    cloudflared

    # Productivity / Knowledge
    (alpaca.override {
      ollama = pkgs.ollama-rocm;
    })
    gnome-feeds
    obsidian
    todoist-electron

    # Media & Utilities
    gnome-calculator
    bluetui
    eartag
    file-roller
    fragments
    gapless
    gradia
    loupe
    mousai
    musicpresence
    parabolic
    showtime
    (callPackage (home-modules + "/packages/spotiflac.nix") { })

    # System Tools
    baobab
    cryptomator

    # Content Creation
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

    # Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # UI
  hypr = {
    primaryMonitor = "DP-1";
    extraLuaConfig = ./monitors.lua;
  };

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
    mpris-proxy.enable = true;
  };

  # Autostart
  systemd.user.services = {
    equibop = {
      Service.ExecStart = "${pkgs.equibop}/bin/equibop --start-minimized";
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
    musicpresence = {
      Service = {
        ExecStart = "${pkgs.musicpresence}/bin/musicpresence";
        Restart = "on-failure";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };

  # Mime
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";

      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/webp" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";

      "video/mp4" = "org.gnome.Showtime.desktop";
      "video/x-matroska" = "org.gnome.Showtime.desktop";

      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/vnd.rar" = "org.gnome.FileRoller.desktop";
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-xz-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-zstd-compressed-tar" = "org.gnome.FileRoller.desktop";
    };
  };
}
