{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.forgejo;
in
{
  options.services.homelab.forgejo = {
    enable = mkEnableOption "Activate the Forgejo Server.";

    user = mkOption {
      type = types.str;
      example = "admin";
      description = "Owner of the reposPath and config files.";
    };

    reposPath = mkOption {
      type = types.str;
      example = "/mnt/forgejo";
      description = "Path to your repos directory.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/containers/forgejo 0750 ${cfg.user} users -"
    ];

    virtualisation.oci-containers.containers.forgejo = {
      image = "codeberg.org/forgejo/forgejo:14-rootless";
      user = "${toString config.users.users.${cfg.user}.uid}:${toString config.users.groups.users.gid}";
      environment = {
        TZ = "America/Maceio";
        FORGEJO____RUN_USER = cfg.user;
        FORGEJO__server__ROOT_URL = "https://fgj.txgfk.xyz/";
        FORGEJO__server__DOMAIN = "fgj.txgfk.xyz";
        FORGEJO__indexer__MAX_FILE_SIZE = "6291456";
        FORGEJO__service__ENABLE_CAPTCHA = "true";
        FORGEJO__service__EMAIL_DOMAIN_BLOCK_DISPOSABLE = "true";
      };
      volumes = [
        "${cfg.reposPath}:/var/lib/gitea"
        "/var/lib/containers/forgejo:/etc/gitea"
        "/etc/localtime:/etc/localtime:ro"
      ];
      ports = [
        "3000:3000"
        "222:2222"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      3000
      222
    ];
  };
}
