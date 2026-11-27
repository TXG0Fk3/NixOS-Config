{
  colors,
  lib,
  pkgs,
  ...
}:

let
  c = colors;
  hex = lib.removePrefix "#";
  font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Medium.ttf";

  # MangoHud is configured through MANGOHUD_CONFIG instead of a config file, because Steam
  # games run inside the pressure-vessel container, which does not see the host's /etc.
  # Logs go to ~/.cache because the container also does not share the whole
  # /run/user/$UID, while $HOME is shared. Multi-value options use `+` because
  # MANGOHUD_CONFIG splits top-level entries on `,`.
  mangohudConfig = lib.concatStringsSep "," [
    # Behavior & logging (feeds Waybar's custom/fps widget)
    "no_display"
    "output_folder=~/.cache/mangohud"
    "log_interval=1000"
    "autostart_log=1"

    # Layout & typography
    "position=top-left"
    "offset_x=10"
    "offset_y=10"
    "round_corners=0"
    "background_alpha=0.85"
    "alpha=1.0"
    "font_file=${font}"
    "font_size=20"
    "text_outline=0"

    # Colors
    "background_color=${hex c.bg}"
    "text_color=${hex c.fg}"
    "gpu_color=${hex c.mid}"
    "cpu_color=${hex c.mid}"
    "vram_color=${hex c.mid}"
    "ram_color=${hex c.mid}"
    "wine_color=${hex c.mid}"
    "engine_color=${hex c.accent}"
    "frametime_color=${hex c.accent}"
    "fps_color_change"
    "fps_value=30+60"
    "fps_color=${hex c.red}+${hex c.yellow}+${hex c.fg}"

    # GPU
    "gpu_stats"
    "gpu_temp"
    "gpu_junction_temp"
    "gpu_core_clock"
    "gpu_mem_clock"
    "gpu_power"
    "gpu_fan"
    "throttling_status"

    # CPU
    "cpu_stats"
    "cpu_temp"
    "cpu_power"
    "cpu_mhz"

    # Memory
    "vram"
    "ram"
    "swap"

    # FPS & frametime
    "fps"
    "frametime"
    "fps_metrics=avg+0.01"
    "frame_timing"
    "show_fps_limit"

    # Engine & runtime
    "engine_version"
    "engine_short_names"
    "vulkan_driver"
    "wine"
    "winesync"
    "gamemode"
    "present_mode"
    "resolution"
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
  hardware.steam-hardware.enable = true;

  # Gamescope & GameMode
  programs.gamescope.enable = true;
  programs.gamemode = {
    enable = true;
    settings.general = {
      renice = 10;
      ioprio = 0;
      desiredgov = "performance";
    };
  };

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
