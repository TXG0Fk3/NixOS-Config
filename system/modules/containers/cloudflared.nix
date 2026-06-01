{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.cloudflared;
in
{
  options.services.homelab.cloudflared = {
    enable = mkEnableOption "Enable Cloudflared service.";

    tunnelTokenFile = mkOption {
      type = types.str;
      description = "Path to file containing TUNNEL_TOKEN environment variable";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.cloudflared = {
      image = "cloudflare/cloudflared:2026.5.2";
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
