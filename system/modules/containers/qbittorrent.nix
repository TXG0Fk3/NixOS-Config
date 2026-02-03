{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.qbittorrent-docker;
in
{
  options.services.qbittorrent-docker = {
    enable = mkEnableOption "Activate the qBittorrent docker container.";

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
    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = false;
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "America/Maceio";
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/home/${cfg.user}/containers/qbittorrent/config:/config"
        "${cfg.storagePath}:/downloads"
      ];
      ports = [ "8080:8080" "6881:6881" "6881:6881/udp" ];
    };

    networking.firewall.allowedTCPPorts = [ 8080 6881 ];
    networking.firewall.allowedUDPPorts = [ 6881 ];
  };
}