{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.filebrowser;
  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "filebrowser-config.yaml" {
    http = {
      port = 8080;
      baseURL = "/";
    };
    server.sources = [
      { path = "/srv"; }
    ];
  };
in
{
  options.services.homelab.filebrowser = {
    enable = lib.mkEnableOption "Activate FileBrowser Web UI.";

    user = lib.mkOption {
      type = lib.types.str;
      default = "admin";
    };

    storagePath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules =
      map (subDir: "d /var/lib/containers/filebrowser${subDir} 0700 ${cfg.user} users -")
        [
          ""
          "/data"
        ];

    virtualisation.oci-containers.containers.filebrowser = {
      image = "ghcr.io/gtsteffaniak/filebrowser:2.0.2-stable";
      autoStart = true;
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        FILEBROWSER_CONFIG = "/etc/filebrowser/config.yaml";
        FILEBROWSER_DATABASE_PATH = "/home/filebrowser/data/database.sqlite";
      };
      volumes = [
        "/var/lib/containers/filebrowser/data:/home/filebrowser/data"
        "${configFile}:/etc/filebrowser/config.yaml:ro"

        "${cfg.storagePath}:/srv/storage"
        "/var/lib/containers:/srv/configs"
        "/home/${cfg.user}:/srv/home-user"
      ];
      ports = [ "127.0.0.1:8090:8080" ];

      # We disable healthchecks because the image defaults to checking port 80.
      # Since we are running as a non-root user and moved the internal port to 8080,
      # the default healthcheck would always fail, causing unnecessary rebuild warnings.
      extraOptions = [ "--no-healthcheck" ];
    };
  };
}
