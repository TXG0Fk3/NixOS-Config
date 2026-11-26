{
  config,
  pkgs,
  inputs,
  secrets,
  home-modules,
  users,
  ...
}:

let
  equibop = pkgs.callPackage (home-modules + "/packages/equibop.nix") { };
in
{
  imports = [
    ./gsr.nix
    ./mime.nix
    (users + "/txg0fk3/common.nix")
    (home-modules + "/bottles.nix")
    (home-modules + "/flatpak.nix")
    (home-modules + "/helix.nix")
    (home-modules + "/hypr")
    (home-modules + "/kdeconnect.nix")
    (home-modules + "/librewolf.nix")
    (home-modules + "/prismlauncher.nix")
    (home-modules + "/zathura.nix")
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Sops
  sops = {
    defaultSopsFile = secrets + "/common.yaml";
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
    hydra = "kitten ssh admin@192.168.1.112";
    hydra-reboot = "ssh -t admin@192.168.1.112 sudo systemctl reboot";
    nfu = "nix flake update";
    nr = "nh os switch .";
    nr-hydra = "nixos-rebuild boot --flake .#Hydra --target-host admin@192.168.1.112 --sudo --ask-sudo-password";
    nrb = "nh os boot .";
  };

  # User Packages
  home.packages = with pkgs; [
    # Network & Streaming & Sharing
    equibop
    localsend
    proton-vpn
    cloudflared

    # Productivity / Knowledge
    antigravity-cli
    antigravity-hub
    github-copilot-cli
    gnome-feeds
    obsidian
    opencode

    # Media & Utilities
    gnome-calculator
    bluetui
    eartag
    file-roller
    fragments
    gapless
    loupe
    mousai
    musicpresence
    parabolic
    showtime

    # System Tools
    baobab
    cryptomator

    # Remote Access
    remmina
    scrcpy
  ];

  # UI
  hypr = {
    primaryMonitor = "DP-1";
    secondaryMonitor = "HDMI-A-1";
    extraLuaConfig = ./hypr.lua;
  };

  # Flatpaks
  services.flatpak.packages = [
    "io.mrarm.mcpelauncher"
    "org.vinegarhq.Sober"
  ];

  # Git
  programs.git.includes = [
    { path = config.sops.templates."git-secrets".path; }
  ];

  # Services
  services = {
    syncthing.enable = true;
    mpris-proxy.enable = true;
  };

  # Autostart
  systemd.user.services = {
    equibop = {
      Unit = {
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${equibop}/bin/equibop --start-minimized";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
    musicpresence = {
      Unit = {
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.musicpresence}/bin/musicpresence";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };

  # Distrobox
  xdg.configFile."distrobox/distrobox.conf".text = ''
    container_home_prefix="$HOME/.local/share/distrobox"
    SHELL="/bin/bash"
  '';
}
