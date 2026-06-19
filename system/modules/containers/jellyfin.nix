{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.jellyfin;
in
{
  options.services.homelab.jellyfin = {
    enable = mkEnableOption "Activate the Jellyfin Media Server.";

    user = mkOption {
      type = types.str;
      example = "admin";
      description = "Owner of the media and config files.";
    };

    mediaPath = mkOption {
      type = types.str;
      example = "/mnt/storage/media";
      description = "Path to your media library.";
    };

    transcodePath = mkOption {
      type = types.str;
      default = "/var/lib/containers/jellyfin/cache/transcode";
      description = "Path for temporary transcode files.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      (map (subDir: "d /var/lib/containers/jellyfin${subDir} 0750 ${cfg.user} users -") [
        ""
        "/config"
        "/cache"
      ])
      ++ [
        "d ${cfg.transcodePath} 0750 ${cfg.user} users -"
      ];

    virtualisation.oci-containers.containers.jellyfin = {
      image = "jellyfin/jellyfin:10.11.11";
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
      };
      volumes = [
        "/var/lib/containers/jellyfin/config:/config"
        "/var/lib/containers/jellyfin/cache:/cache"
        "${cfg.mediaPath}:/media"
        "${cfg.transcodePath}:/transcode"
      ];
      ports = [
        "8096:8096/tcp"
        "7359:7359/udp"
      ];
      extraOptions = [
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--device=/dev/dri/card1:/dev/dri/card1"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 8096 ];
    networking.firewall.allowedUDPPorts = [ 7359 ];
  };
}
