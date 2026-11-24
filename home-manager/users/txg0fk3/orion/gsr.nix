{
  config,
  lib,
  pkgs,
  ...
}:

let
  gsrPatchConfig = pkgs.writeShellScript "gsr-patch-config" ''
    cfg="${config.xdg.configHome}/gpu-screen-recorder/config_ui"
    if [ -f "$cfg" ]; then
      tmp=$(${pkgs.coreutils}/bin/mktemp)
      ${pkgs.jq}/bin/jq '
        .main.hotkeys_enable_option = "enable_hotkeys_no_grab" |
        .main.rounded_corners = false |
        .main.tint_color = "intel" |
        .main.show_tray_icon = false |
        .main.show_hide_hotkey = { "key": 0, "modifiers": 0 } |
        .screenshot.take_screenshot_hotkey = { "key": 0, "modifiers": 0 } |
        .screenshot.take_screenshot_region_hotkey = { "key": 0, "modifiers": 0 } |
        .screenshot.take_screenshot_window_hotkey = { "key": 0, "modifiers": 0 }
      ' "$cfg" > "$tmp" && ${pkgs.coreutils}/bin/mv "$tmp" "$cfg"
    fi
  '';
in
{
  systemd.user.services.gsr-ui = {
    Unit = {
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStartPre = "${gsrPatchConfig}";
      ExecStart = "/run/current-system/sw/bin/gsr-ui launch-daemon";
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  home.activation.gsrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${gsrPatchConfig}
    /run/current-system/sw/bin/gsr-ui-cli reload-config >/dev/null 2>&1 || true
  '';
}
