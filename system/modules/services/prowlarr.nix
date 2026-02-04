{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.prowlarr;
in
{
  options.services.homelab.prowlarr = {
    enable = mkEnableOption "Enable the Prowlarr indexer.";
  };

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
    };

    networking.firewall.allowedTCPPorts = [ 9696 ];
  };
}