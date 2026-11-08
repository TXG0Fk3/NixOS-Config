{ pkgs, ... }:

{
  home.packages = with pkgs; [
    just
    onefetch
    ouch-rar
    tokei
  ];

  programs = {
    bat = {
      enable = true;
      config.theme = "ansi";
    };
    fd.enable = true;
    ripgrep.enable = true;
    lazygit.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    zellij = {
      enable = true;
      enableZshIntegration = false;
    };
    gh.enable = true;
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
