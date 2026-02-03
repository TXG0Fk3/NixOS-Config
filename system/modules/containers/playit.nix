{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.playit;
in
{
  options.services.homelab.playit = {
    enable = mkEnableOption "Activate the Playit.gg agent.";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/playit 0700 root root -"
    ];

    virtualisation.oci-containers.containers.playit = {
      image = "ghcr.io/playit-cloud/playit-agent:0.16";
      autoStart = false;
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        "/var/lib/playit/playit.env"
      ];
    };
  };
}