{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.playit;
in
{
  options.services.homelab.playit = {
    enable = mkEnableOption "Activate the Playit.gg agent.";

    secretKeyFile = mkOption {
      type = types.str;
      description = "Path to file containing SECRET_KEY environment variable
";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.playit = {
      image = "ghcr.io/playit-cloud/playit-agent:0.16";
      autoStart = false;
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        cfg.secretKeyFile
      ];
    };
  };
}
