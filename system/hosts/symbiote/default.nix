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

  # Network
  networking.hostName = "Symbiote";

  # Users
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Languages / Runtimes
    bun
    go
    python3

    # CLI Tools
    curl
    git
    tree

    # Terminal / Productivity
    superfile
    zellij

    # Nix tooling
    nixfmt
    nixfmt-tree
  ];

  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
