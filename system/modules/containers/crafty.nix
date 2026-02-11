{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.crafty;
in
{
  options.services.homelab.crafty = {
    enable = mkEnableOption "Activate the Crafty service.";

    user = mkOption {
      type = types.str;
      default = "admin";
      description = "The username that will own the configs";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      map (subDir: "d /var/lib/containers/crafty${subDir} 0750 ${cfg.user} users -")
        [
          ""
          "/backups"
          "/logs"
          "/servers"
          "/config"
          "/import"
        ];

    virtualisation.oci-containers.containers.crafty = {
      image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
      autoStart = false;
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
      };
      volumes = [
        "/var/lib/containers/crafty/backups:/crafty/backups"
        "/var/lib/containers/crafty/logs:/crafty/logs"
        "/var/lib/containers/crafty/servers:/crafty/servers"
        "/var/lib/containers/crafty/config:/crafty/app/config"
        "/var/lib/containers/crafty/import:/crafty/import"
      ];
      ports = [
        "8443:8443"
        "8123:8123"
        "19132:19132/udp"
        "25500-25600:25500-25600"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 8443 ];
    networking.firewall.allowedUDPPorts = [ 19132 ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 25500;
        to = 25600;
      }
    ];
  };
}
