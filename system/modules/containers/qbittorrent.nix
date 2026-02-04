{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.qbittorrent;
in
{
  options.services.homelab.qbittorrent = {
    enable = mkEnableOption "Activate the qBittorrent service.";

    user = mkOption {
      type = types.str;
      default = "admin";
      description = "The username that will own the config and downloads.";
    };
    
    storagePath = mkOption {
      type = types.str;
      description = "The path where downloads will be saved (must be an absolute path string).";
      example = "/mnt/storage/downloads";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = (map (subDir: 
      "d /var/lib/containers/qbittorrent${subDir} 0755 ${cfg.user} users -"
    ) [ "" "/config" ]) ++ [
      "d ${cfg.storagePath} 0775 ${cfg.user} users -"
    ];

    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      environment = {
        PUID = toString config.users.users.${cfg.user}.uid;
        PGID = "100";
        TZ = "America/Maceio";
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/var/lib/containers/qbittorrent/config:/config"
        "${cfg.storagePath}:${cfg.storagePath}"
      ];
      ports = [ "8080:8080" "6881:6881" "6881:6881/udp" ];
    };

    users.users.radarr.extraGroups = [ "users" ];

    networking.firewall.allowedTCPPorts = [ 8080 6881 ];
    networking.firewall.allowedUDPPorts = [ 6881 ];
  };
}