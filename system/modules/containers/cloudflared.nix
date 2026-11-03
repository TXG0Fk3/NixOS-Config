{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.homelab.cloudflared;
in
{
  options.services.homelab.cloudflared = {
    enable = lib.mkEnableOption "Enable Cloudflared service.";

    tunnelTokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing TUNNEL_TOKEN environment variable";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.cloudflared = {
      image = "docker.io/cloudflare/cloudflared:2026.10.4";
      autoStart = true;
      cmd = [
        "tunnel"
        "--no-autoupdate"
        "run"
      ];
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        cfg.tunnelTokenFile
      ];
    };
  };
}
