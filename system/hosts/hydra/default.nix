{
  config,
  pkgs,
  secreats,
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
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
      ];
      allowedUDPPorts = [
        5520 # Hyale Server
      ];
    };
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
  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "podman"
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Tools
    git
    curl
    zellij
    superfile

    # JRE
    javaPackages.compiler.temurin-bin.jre-25

    # Containers
    podman-compose
  ];

  # Containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Services
  services = {
    openssh.enable = true;
    fail2ban.enable = true;

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

  system.stateVersion = "25.11";
}
