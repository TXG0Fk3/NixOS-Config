{ config, pkgs, ... }:

{
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableXfwm = false;
    enableWaylandSession = true;
    waylandSessionCompositor = "labwc --startup";
  };
}
