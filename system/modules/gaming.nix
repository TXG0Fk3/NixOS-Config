{
  lib,
  pkgs,
  ...
}:

let
  # MangoHud is configured through MANGOHUD_CONFIG instead of a config file, because Steam
  # games run inside the pressure-vessel container, which does not see the host's /etc.
  # Logs go to ~/.cache because the container also does not share the whole
  # /run/user/$UID, while $HOME is shared.
  mangohudConfig = lib.concatStringsSep "," [
    "no_display"
    "output_folder=~/.cache/mangohud"
    "log_interval=1000"
    "autostart_log=1"
  ];
in
{
  # Steam
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
        MANGOHUD_CONFIG = mangohudConfig;
      };
    };
    extraPackages = with pkgs; [
      lsfg-vk
      mangohud
    ];
  };

  # Gamescope & GameMode
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # MangoHud, LSFG-VK & Gaming Tools
  environment.systemPackages = with pkgs; [
    lsfg-vk
    lsfg-vk-ui
    mangohud
    protonplus
    steam-run
  ];
  environment.sessionVariables.MANGOHUD_CONFIG = mangohudConfig;
}
