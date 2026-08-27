{
  config,
  pkgs,
  system-modules,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./mounts.nix
    ./sops.nix
    system-modules
    (system-modules + "/containers/cloudflared.nix")
    (system-modules + "/containers/filebrowser.nix")
    (system-modules + "/containers/syncthing.nix")
    (system-modules + "/containers/forgejo.nix")
    (system-modules + "/containers/qbittorrent.nix")
    (system-modules + "/containers/jellyfin.nix")
    (system-modules + "/containers/crafty.nix")
    (system-modules + "/containers/playit.nix")
  ];

  # Bootloader and Kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };

  # Swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 12 * 1024;
    }
  ];
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "lz4";
    priority = 100;
  };

  # Network
  networking = {
    hostName = "Hydra";
    defaultGateway = "192.168.1.1";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [
        5520 # Hyale Server

        27015 # Query port for Steam server browser
        7777 # ARK Game client port
        7778 # Raw UDP socket port (always Game client port + 1)
      ];
    };

    # Onboard NIC
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.1.112";
        prefixLength = 24;
      }
    ];
  };

  # Hardware
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        libva
      ];
    };
    enableRedistributableFirmware = true;
  };

  # Users.
  users.defaultUserShell = pkgs.zsh;
  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
  };

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    interactiveShellInit = ''
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char

      fastfetch -c minimal
    '';
    shellAliases = {
      nr = "sudo nixos-rebuild boot --flake github:TXG0Fk3/NixOS-Config#Hydra";
      rb = "sudo systemctl reboot";
      ngc = "sudo nix-collect-garbage -d";
    };
    ohMyZsh = {
      enable = true;
      theme = "risto";
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Tools
    git
    curl
    zellij
    superfile
    steamcmd

    # JRE
    javaPackages.compiler.temurin-bin.jre-25

    # Virtualisation
    distrobox

    # Containers
    podman-compose
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      openssl
      glibc
      libgcc
      zlib
    ];
  };

  # Containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Services
  services = {
    openssh.enable = true;
    fail2ban.enable = true;
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."ts-key".path;
    };

    homelab = {
      cloudflared = {
        enable = true;
        tunnelTokenFile = config.sops.secrets."cloudflared.env".path;
      };
      filebrowser = {
        enable = true;
        user = "admin";
        storagePath = "/mnt";
      };
      syncthing = {
        enable = true;
        user = "admin";
        cloudPath = "/mnt/cloud";
      };
      forgejo = {
        enable = true;
        user = "admin";
        reposPath = "/mnt/forgejo";
      };
      qbittorrent = {
        enable = true;
        user = "admin";
        storagePath = "/mnt/scratch/torrents";
      };
      jellyfin = {
        enable = true;
        user = "admin";
        mediaPath = "/mnt/media";
        transcodePath = "/mnt/scratch/jellyfin/transcode";
      };
      crafty = {
        enable = true;
        user = "admin";
      };
      playit = {
        enable = true;
        secretKeyFile = config.sops.secrets."playit.env".path;
      };
    };

    radarr = {
      enable = true;
      user = "admin";
      openFirewall = true; # 7878
    };
    sonarr = {
      enable = true;
      user = "admin";
      openFirewall = true; # 8989
    };
    bazarr = {
      enable = false;
      user = "admin";
      openFirewall = false; # 6767
    };
    prowlarr = {
      enable = true;
      openFirewall = true; # 9696
    };
  };

  system.stateVersion = "26.05";
}
