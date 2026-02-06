{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.filebrowser;
in
{
  options.services.homelab.filebrowser = {
    enable = mkEnableOption "Activate FileBrowser Web UI.";

    user = mkOption { 
      type = types.str;
      default = "admin";
    };

    storagePath = mkOption {
      type = types.str;
      default = "/mnt/storage";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = map (subDir: 
      "d /var/lib/containers/filebrowser${subDir} 0700 ${cfg.user} users -"
    ) [ "" "/db" "/conf" ];

    virtualisation.oci-containers.containers.filebrowser = {
      image = "filebrowser/filebrowser:latest";
      autoStart = true;
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      cmd = [ 
        "--port" "8080"
        "--address" "0.0.0.0"
        "--database" "/database/filebrowser.db"
        "--root" "/srv"
      ];
      volumes = [
        "/var/lib/containers/filebrowser/db:/database"
        "/var/lib/containers/filebrowser/conf:/config"

        "${cfg.storagePath}:/srv/storage"
        "/var/lib/containers:/srv/configs"
        "/home/${cfg.user}:/srv/home-user"
      ];
      ports = [ "8090:8080" ];

      # We disable healthchecks because the official image defaults to checking port 80.
      # Since we are running as a non-root user and moved the internal port to 8080,
      # the default healthcheck would always fail, causing unnecessary rebuild warnings.
      extraOptions = [ "--no-healthcheck" ];
    };

    networking.firewall.allowedTCPPorts = [ 8090 ];
  };
}