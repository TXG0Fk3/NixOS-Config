{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.syncthing;
in
{
  options.services.homelab.syncthing = {
    enable = mkEnableOption "Activate the Syncthing container.";

    user = mkOption {
      type = types.str;
      example = "admin";
      description = "Owner of the cloudPath and config files.";
    };

    cloudPath = mkOption {
      type = types.str;
      example = "/mnt/cloud";
      description = "Path to your files.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/containers/syncthing 0750 ${cfg.user} users -"
    ];

    virtualisation.oci-containers.containers.syncthing = {
      image = "syncthing/syncthing:2.1.2";
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
      };
      volumes = [
        "/var/lib/containers/syncthing:/var/syncthing"
        "${cfg.cloudPath}:/cloud"
      ];
      ports = [
        "8384:8384"
        "22000:22000/tcp"
        "22000:22000/udp"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      8384
      22000
    ];
    networking.firewall.allowedUDPPorts = [ 22000 ];
  };
}
