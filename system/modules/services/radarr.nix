{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.radarr;
in
{
  options.services.homelab.radarr = {
    enable = mkEnableOption "Enable the native Radar service..";
    
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/radarr";
      description = "Radarr database and configuration directory.";
    };

    moviesPath = mkOption {
      type = types.str;
      description = "Final path to the media library.";
      example = "/mnt/storage/media/movies";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.moviesPath} 0775 root users -"
    ];

    services.radarr = {
      enable = true;
      dataDir = cfg.dataDir;
    };
    
    users.users.radarr.extraGroups = [ "users" ];

    networking.firewall.allowedTCPPorts = [ 7878 ];
  };
}