{ lib, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    setOptions = [
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
    ];
    interactiveShellInit = ''
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

      ${lib.getExe pkgs.nix-your-shell} zsh | source /dev/stdin

      fastfetch -c minimal
    '';
    shellAliases = {
      ngc = "nh clean all";
    };
  };
}
