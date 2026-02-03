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
      user = "1000:100";
      volumes = [
        "/var/lib/containers/filebrowser/db:/database"
        "/var/lib/containers/filebrowser/conf:/config"
        
        "${cfg.storagePath}:/srv/storage"
        "/var/lib/containers:/srv/configs"
        "/home/${cfg.user}:/srv/home-user"
      ];
      ports = [ "8090:80" ];
    };

    networking.firewall.allowedTCPPorts = [ 8090 ];
  };
}