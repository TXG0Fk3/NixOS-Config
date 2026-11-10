{
  config,
  lib,
  ...
}:

let
  cfg = config.services.homelab.jellyfin;
in
{
  options.services.homelab.jellyfin = {
    enable = lib.mkEnableOption "Activate the Jellyfin Media Server.";

    user = lib.mkOption {
      type = lib.types.str;
      example = "admin";
      description = "Owner of the media and config files.";
    };

    mediaPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = [ "/mnt/storage/media" ];
      description = "Paths to your media libraries. Mounted at /media, /media2, ... in the container.";
    };

    transcodePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/containers/jellyfin/cache/transcode";
      description = "Path for temporary transcode files.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules =
      (map (subDir: "d /var/lib/containers/jellyfin${subDir} 0750 ${cfg.user} users -") [
        ""
        "/config"
        "/cache"
      ])
      ++ [
        "d ${cfg.transcodePath} 0750 ${cfg.user} users -"
      ];

    systemd.services."podman-jellyfin".unitConfig.RequiresMountsFor = cfg.mediaPaths ++ [
      cfg.transcodePath
    ];

    virtualisation.oci-containers.containers.jellyfin = {
      image = "docker.io/jellyfin/jellyfin:12.4";
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
      };
      volumes = [
        "/var/lib/containers/jellyfin/config:/config"
        "/var/lib/containers/jellyfin/cache:/cache"
        "${cfg.transcodePath}:/transcode"
      ]
      ++ (lib.imap1 (i: path: "${path}:/media${if i == 1 then "" else toString i}") cfg.mediaPaths);
      ports = [
        "127.0.0.1:8096:8096/tcp"
        "7359:7359/udp"
      ];
      extraOptions = [
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--device=/dev/dri/card1:/dev/dri/card1"
      ];
    };

    networking.firewall.allowedUDPPorts = [ 7359 ];
  };
}
