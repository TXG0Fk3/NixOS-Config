{
  colors,
  pkgs,
  ...
}:

let
  c = colors;

  screenAnnotate = pkgs.writeShellScriptBin "screen-annotate" ''
    set -o pipefail

    tmp=$(${pkgs.coreutils}/bin/mktemp --suffix=.png)
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

    # hyprshot exits non-zero even on success
    ${pkgs.hyprshot}/bin/hyprshot -m region -s --raw 2>/dev/null \
      | ${pkgs.coreutils}/bin/cat > "$tmp" || true

    if [ ! -s "$tmp" ]; then
      exit 0
    fi

    pictures=$(${pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)
    output="$pictures/Screenshots/Screenshot-$(${pkgs.coreutils}/bin/date +'%Y-%m-%d_%H-%M-%S').png"
    ${pkgs.coreutils}/bin/mkdir -p "$pictures/Screenshots"

    if ! ${pkgs.satty}/bin/satty --filename "$tmp" --output-filename "$output"; then
      ${pkgs.dunst}/bin/dunstify -a "screen-annotate" "Annotation" "satty failed"
      exit 1
    fi
  '';
in
{
  home.packages = [ screenAnnotate ];

  programs.satty = {
    enable = true;

    settings = {
      general = {
        early-exit = [ "all" ];
        save-after-copy = true;
        copy-command = "${pkgs.wl-clipboard}/bin/wl-copy";
        actions-on-enter = [ "save-to-clipboard" ];
        actions-on-escape = [ "exit" ];
      };

      color-palette.palette = [
        c.accent
        c.red
        c.yellow
        c.green
        c.blue
        c.pink
        c.orange
      ];
    };
  };
}
