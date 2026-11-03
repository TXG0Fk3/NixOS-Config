{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.playit;
in
{
  options.services.homelab.playit = {
    enable = lib.mkEnableOption "Activate the Playit.gg agent.";

    secretKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing SECRET_KEY environment variable";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.playit = {
      image = "ghcr.io/playit-cloud/playit-agent:1.0.10";
      autoStart = false;
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        cfg.secretKeyFile
      ];
    };
  };
}
