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
  wsl.startMenuLaunchers = true;

  # Network
  networking.hostName = "Symbiote";

  # Users
  users.defaultUserShell = pkgs.zsh;
  users.users.TXG0Fk3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    shellAliases = {
      nr = "sudo nixos-rebuild boot --flake github:TXG0Fk3/NixOS-Config#Symbiote";
      ngc = "sudo nix-collect-garbage -d";
    };
    ohMyZsh = {
      enable = true;
      theme = "risto";
    };
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
