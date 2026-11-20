{
  colors,
  lib,
  pkgs,
  ...
}:

let
  c = colors;

  monosquarePlymouth =
    pkgs.runCommand "plymouth-theme-monosquare"
      {
        nativeBuildInputs = [ pkgs.librsvg ];
      }
      ''
        dir="$out/share/plymouth/themes/monosquare"
        mkdir -p "$dir"

        # White NixOS snowflake (transparent background)
        rsvg-convert -w 96 -h 96 \
          "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg" \
          -o "$dir/logo.png"

        # Solid white square (10x10)
        cat > dot-on.svg <<'EOF'
        <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 10 10">
          <rect x="0" y="0" width="10" height="10" fill="${c.fg}"/>
        </svg>
        EOF
        rsvg-convert -w 10 -h 10 dot-on.svg -o "$dir/dot-on.png"

        # Black square (10x10)
        cat > dot-off.svg <<'EOF'
        <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 10 10">
          <rect x="0" y="0" width="10" height="10" fill="${c.bg}"/>
        </svg>
        EOF
        rsvg-convert -w 10 -h 10 dot-off.svg -o "$dir/dot-off.png"

        cat > "$dir/monosquare.plymouth" <<EOF
        [Plymouth Theme]
        Name=Monosquare
        Description=Minimalist black and white Monosquare theme
        ModuleName=script

        [script]
        ImageDir=$dir
        ScriptFile=$dir/monosquare.script
        ConsoleLogBackgroundColor=0x00000000
        EOF

        cat > "$dir/monosquare.script" <<'EOF'
        Window.SetBackgroundTopColor(0.0, 0.0, 0.0);
        Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

        logo.image = Image("logo.png");
        logo.sprite = Sprite(logo.image);

        dot_on_img = Image("dot-on.png");
        dot_off_img = Image("dot-off.png");

        num_dots = 5;
        dot_size = 10;
        dot_gap = 12;
        logo_gap = 28;
        total_dots_w = num_dots * dot_size + (num_dots - 1) * dot_gap;
        total_h = logo.image.GetHeight() + logo_gap + dot_size;

        for (i = 0; i < num_dots; i++) {
          dots[i].sprite = Sprite(dot_off_img);
        }

        fun layout_sprites() {
          global.cx = Window.GetX() + Window.GetWidth() / 2;
          global.cy = Window.GetY() + Window.GetHeight() / 2;

          top_y = cy - total_h / 2;
          logo.sprite.SetPosition(cx - logo.image.GetWidth() / 2, top_y, 10);

          dots_start_x = cx - total_dots_w / 2;
          global.dots_y = top_y + logo.image.GetHeight() + logo_gap;
          for (i = 0; i < num_dots; i++) {
            dots[i].sprite.SetPosition(dots_start_x + i * (dot_size + dot_gap), dots_y, 20);
          }
        }

        layout_sprites();

        status = "normal";
        tick = 0;
        pos = 0;

        fun refresh_callback() {
          layout_sprites();
          if (status == "normal") {
            tick++;
            if (tick >= 6) {
              tick = 0;
              pos = (pos + 1) % num_dots;
              for (i = 0; i < num_dots; i++) {
                if (i == pos) {
                  dots[i].sprite.SetImage(dot_on_img);
                } else {
                  dots[i].sprite.SetImage(dot_off_img);
                }
              }
            }
          }
        }

        Plymouth.SetRefreshFunction(refresh_callback);

        fun set_dots_opacity(op) {
          for (i = 0; i < num_dots; i++) {
            dots[i].sprite.SetOpacity(op);
          }
        }

        fun hide_bullets() {
          for (i = 0; dialog.bullet[i]; i++) {
            dialog.bullet[i].sprite.SetOpacity(0);
          }
        }

        fun display_normal_callback() {
          global.status = "normal";
          hide_bullets();
          set_dots_opacity(1);
        }

        fun display_password_callback(prompt, bullets) {
          global.status = "password";
          set_dots_opacity(0);

          max_bullets = 14;
          shown = bullets;
          if (shown > max_bullets) shown = max_bullets;

          b_gap = 8;
          total_w = shown * dot_size + (shown - 1) * b_gap;
          start_x = cx - total_w / 2;

          for (i = 0; dialog.bullet[i] || i < shown; i++) {
            if (!dialog.bullet[i]) {
              dialog.bullet[i].sprite = Sprite(dot_on_img);
            }
            if (i < shown) {
              dialog.bullet[i].sprite.SetPosition(start_x + i * (dot_size + b_gap), dots_y, 30);
              dialog.bullet[i].sprite.SetOpacity(1);
            } else {
              dialog.bullet[i].sprite.SetOpacity(0);
            }
          }
        }

        Plymouth.SetDisplayNormalFunction(display_normal_callback);
        Plymouth.SetDisplayPasswordFunction(display_password_callback);
        EOF
      '';
in
{
  # Silent Boot & Splash
  boot = {
    consoleLogLevel = lib.mkDefault 3;
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=auto"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
    ];

    # Plymouth
    plymouth = {
      enable = true;
      theme = "monosquare";
      themePackages = [ monosquarePlymouth ];
      font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Bold.ttf";
    };
  };
}
