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
    (home-modules + "/fastfetch.nix")
    (home-modules + "/superfile.nix")
    (home-modules + "/cli.nix")
    (home-modules + "/nix-index.nix")
    (home-modules + "/btop.nix")
  ];

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    history.ignoreDups = true;
    history.ignoreSpace = true;
    initContent = ''
      WORDCHARS='*?_[]~=&;!#$%^(){}<>'

      bindkey "^[[H" beginning-of-line
      bindkey "^[OH" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[OF" end-of-line
      bindkey "^[[3~" delete-char

      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;3D" backward-word
      bindkey "^[[1;3C" forward-word

      bindkey "^H" backward-kill-word
      bindkey "^[[127;5u" backward-kill-word
      bindkey "^[^?" backward-kill-word
      bindkey "^[[3;5~" kill-word
      bindkey "^[[3;3~" kill-word

      fastfetch -c minimal
    '';
  };
}
