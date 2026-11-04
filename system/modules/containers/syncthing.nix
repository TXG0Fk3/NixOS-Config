{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.syncthing;
in
{
  options.services.homelab.syncthing = {
    enable = lib.mkEnableOption "Activate the Syncthing container.";

    user = lib.mkOption {
      type = lib.types.str;
      example = "admin";
      description = "Owner of the cloudPath and config files.";
    };

    cloudPath = lib.mkOption {
      type = lib.types.str;
      example = "/mnt/cloud";
      description = "Path to your files.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/containers/syncthing 0750 ${cfg.user} users -"
    ];

    systemd.services."podman-syncthing".unitConfig.RequiresMountsFor = [ cfg.cloudPath ];

    virtualisation.oci-containers.containers.syncthing = {
      image = "docker.io/syncthing/syncthing:2.1.7";
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
      };
      volumes = [
        "/var/lib/containers/syncthing:/var/syncthing"
        "${cfg.cloudPath}:/cloud"
      ];
      ports = [
        "127.0.0.1:8384:8384"
        "22000:22000/tcp"
        "22000:22000/udp"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 ];
  };
}
