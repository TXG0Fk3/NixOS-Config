{
  config,
  pkgs,
  home-modules,
  ...
}:

{
  home.username = "TXG0Fk3";
  home.homeDirectory = "/home/TXG0Fk3";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    initContent = ''
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char

      fastfetch -c minimal
    '';
    shellAliases = {
      brain-sync = "cd ~/Brain && git add . && git commit -m \"🧠 Brain update: $(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main";
      usbmds = "sudo usb_modeswitch -v 0bda -p 1a2b -K";
    };
  };
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "catppuccin_mocha";
  };
}
