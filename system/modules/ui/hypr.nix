{ config, pkgs, ... }:

{
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };
  programs.hyprland.enable = true;

  security.pam.services.hyprlock = { };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
