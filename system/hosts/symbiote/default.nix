{
  config,
  lib,
  pkgs,
  system-modules,
  ...
}:

{
  imports = [ system-modules ];

  wsl.enable = true;
  wsl.defaultUser = "TXG0Fk3";

  services.resolved.enable = false;

  programs.nix-ld.enable = true;

  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "25.11";
}