{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.cloudflared;
in
{
  options.services.homelab.cloudflared = {
    enable = mkEnableOption "Enable Cloudflared service.";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/containers/cloudflared 0700 root root -"
    ];

    virtualisation.oci-containers.containers.cloudflared = {
      image = "cloudflare/cloudflared:latest";
      autoStart = true;
      cmd = [ "tunnel" "--no-autoupdate" "run" ];
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        "/var/lib/containers/cloudflared/cloudflared.env"
      ];
    };
  };
}