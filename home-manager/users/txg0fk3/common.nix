{
  home-modules,
  ...
}:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "26.05";

  nixpkgs.config.allowUnfree = true;

  imports = [
    (home-modules + "/superfile.nix")
    (home-modules + "/cli.nix")
    (home-modules + "/nix-index.nix")
    (home-modules + "/btop.nix")
  ];

  # Shell
  programs.zsh.enable = true;
}
