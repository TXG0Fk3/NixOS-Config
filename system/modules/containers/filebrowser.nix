{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.filebrowser;
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
          "/db"
          "/conf"
        ];

    virtualisation.oci-containers.containers.filebrowser = {
      image = "docker.io/filebrowser/filebrowser:v2.63.23";
      autoStart = true;
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      cmd = [
        "--port"
        "8080"
        "--address"
        "0.0.0.0"
        "--database"
        "/database/filebrowser.db"
        "--root"
        "/srv"
      ];
      volumes = [
        "/var/lib/containers/filebrowser/db:/database"
        "/var/lib/containers/filebrowser/conf:/config"

        "${cfg.storagePath}:/srv/storage"
        "/var/lib/containers:/srv/configs"
        "/home/${cfg.user}:/srv/home-user"
      ];
      ports = [ "127.0.0.1:8090:8080" ];

      # We disable healthchecks because the official image defaults to checking port 80.
      # Since we are running as a non-root user and moved the internal port to 8080,
      # the default healthcheck would always fail, causing unnecessary rebuild warnings.
      extraOptions = [ "--no-healthcheck" ];
    };
  };
}
