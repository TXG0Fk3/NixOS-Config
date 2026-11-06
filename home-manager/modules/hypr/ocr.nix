{
  pkgs,
  ...
}:

let
  tesseract = pkgs.tesseract.override {
    enableLanguages = [
      "eng"
      "por"
    ];
  };

  screenOcr = pkgs.writeShellScriptBin "screen-ocr" ''
    set -o pipefail

    # hyprshot exits non-zero even on success
    text=$({ ${pkgs.hyprshot}/bin/hyprshot -m region -s --raw 2>/dev/null || true; } \
      | ${tesseract}/bin/tesseract stdin stdout -l por+eng 2>/dev/null \
      | ${pkgs.coreutils}/bin/tr -d '\f') || exit 0

    if [ -z "$(printf '%s' "$text" | ${pkgs.coreutils}/bin/tr -d '[:space:]')" ]; then
      ${pkgs.dunst}/bin/dunstify -a "screen-ocr" "OCR" "No text recognized"
      exit 0
    fi

    printf '%s' "$text" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.dunst}/bin/dunstify -a "screen-ocr" "OCR" "Copied ''${#text} characters"
  '';
in
{
  home.packages = [ screenOcr ];
}
