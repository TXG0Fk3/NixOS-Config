{
  config,
  lib,
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
      image = "docker.io/cloudflare/cloudflared:2026.11.2";
      autoStart = true;
      cmd = [
        "tunnel"
        "--no-autoupdate"
        # Force HTTP/2 over TCP to avoid ISP UDP/QUIC throttling on port 7844
        "--protocol"
        "http2"
        "run"
      ];
      extraOptions = [ "--network=host" ];
      environmentFiles = [
        cfg.tunnelTokenFile
      ];
    };
  };
}
