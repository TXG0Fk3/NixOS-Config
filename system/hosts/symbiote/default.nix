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

  # Users
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Tools
    git
    curl
    zellij
    superfile
  ];

  programs.nix-ld.enable = true;

  system.stateVersion = "25.11";
}