{
  colors,
  lib,
  pkgs,
  ...
}:

let
  c = colors;

  hex = s: lib.toUpper (lib.removePrefix "#" s);

  # Ly 32-bit color format: 0xSSRRGGBB (TB_HI_BLACK = 0x20000000, TB_BOLD = 0x01000000)
  lyBlack = "0x20000000";
  lyWhite = "0x00${hex c.fg}";
  lyBoldWhite = "0x01${hex c.fg}";
  lyBoldRed = "0x01${hex c.red}";

  # Mirrors the Monosquare hyprlock layout: a solid white card above the login box
  # with solid black 5x5 digits (HH:MM) and DD/MM/YYYY date.
  # Note: Ly's embedded LuaJIT omits the `os` stdlib, so TZ_OFFSET_SEC matches
  # `time.timeZone = "America/Maceio"` (UTC-3) in system/modules/default.nix.
  lyAnimLua = pkgs.writeText "ly-monosquare.lua" ''
    local WHITE = ${lyWhite}
    local BLACK = ${lyBlack}
    local SPACE = 32

    -- Geometry matching Ly's login box:
    -- box: margin_h=2, margin_v=1, input_len=34, labels_max_length=8 -> width=47, height=9
    -- With bigclock disabled, Ly centers the 47x9 box directly.
    -- We draw a matching 49x9 solid white block directly above the login box
    -- with crisp solid black digits (HH:MM) and date (DD/MM/YYYY), mirroring hyprlock.
    local BOX_W = 47
    local BOX_H = 9
    local BLOCK_W = BOX_W + 2
    local BLOCK_H = 9
    local BLOCK_GAP = 2

    -- 5x5 solid pixel digits (rendered with solid black background cells, zero dithering)
    local DIGITS = {
      ["0"] = { "11111", "11011", "11011", "11011", "11111" },
      ["1"] = { "00110", "01110", "00110", "00110", "01111" },
      ["2"] = { "11111", "00011", "11111", "11000", "11111" },
      ["3"] = { "11111", "00011", "11111", "00011", "11111" },
      ["4"] = { "11011", "11011", "11111", "00011", "00011" },
      ["5"] = { "11111", "11000", "11111", "00011", "11111" },
      ["6"] = { "11111", "11000", "11111", "11011", "11111" },
      ["7"] = { "11111", "00011", "00011", "00011", "00011" },
      ["8"] = { "11111", "11011", "11111", "11011", "11111" },
      ["9"] = { "11111", "11011", "11111", "00011", "11111" },
      [":"] = { "00000", "00100", "00000", "00100", "00000" },
    }

    -- America/Maceio is UTC-3 (no DST)
    local TZ_OFFSET_SEC = -3 * 3600

    local function civil_from_days(z)
      z = z + 719468
      local era = math.floor(z / 146097)
      local doe = z - era * 146097
      local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
      local y = yoe + era * 400
      local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
      local mp = math.floor((5 * doy + 2) / 153)
      local d = doy - math.floor((153 * mp + 2) / 5) + 1
      local m = mp + (mp < 10 and 3 or -9)
      if m <= 2 then y = y + 1 end
      return d, m, y
    end

    local function get_local_datetime()
      local total_sec = math.floor(ly.clock() / 1000000) + TZ_OFFSET_SEC
      local days = math.floor(total_sec / 86400)
      local rem = total_sec - days * 86400
      local hour = math.floor(rem / 3600)
      local min = math.floor((rem % 3600) / 60)
      local d, m, y = civil_from_days(days)
      return string.format("%02d:%02d", hour, min), string.format("%02d/%02d/%04d", d, m, y)
    end

    local function draw_digit(ch, x, y)
      local rows = DIGITS[ch]
      if not rows then return end
      for r = 1, 5 do
        local row = rows[r]
        for col = 1, 5 do
          if string.sub(row, col, col) == "1" then
            ly.putCell(SPACE, BLACK, BLACK, x + col - 1, y + r - 1)
          end
        end
      end
    end

    function draw()
      local w = ly.width
      local h = ly.height
      if w < BLOCK_W + 4 or h < BOX_H + BLOCK_H + BLOCK_GAP + 4 then
        return
      end

      -- Match Ly's box centering (box_position_v = 0.62, box_position_h = 0.5)
      local dheight = (h > BOX_H + 1) and (h - BOX_H - 1) or 1
      local dwidth = (w > BOX_W + 1) and (w - BOX_W - 1) or 1

      local box_y = math.floor((h - BOX_H) * 0.62)
      if box_y < 1 then box_y = 1 elseif box_y > dheight then box_y = dheight end

      local box_x = math.floor((w - BOX_W) * 0.5)
      if box_x < 1 then box_x = 1 elseif box_x > dwidth then box_x = dwidth end

      local block_x = box_x - 1
      local block_y = box_y - 1 - BLOCK_GAP - BLOCK_H
      if block_x < 0 or block_y < 0 then
        return
      end

      -- Solid white brutalist card above the login box (like hyprlock's 340x150 white shape)
      ly.putRect(SPACE, BLACK, WHITE, block_x, block_y, BLOCK_W, BLOCK_H)

      local time_str, date_str = get_local_datetime()

      -- 5 chars * 5 wide + 4 gaps of 2 = 33 columns
      local clock_x = block_x + math.floor((BLOCK_W - 33) / 2)
      local clock_y = block_y + 1
      for i = 1, #time_str do
        local ch = string.sub(time_str, i, i)
        draw_digit(ch, clock_x + (i - 1) * 7, clock_y)
      end

      local date_x = block_x + math.floor((BLOCK_W - #date_str) / 2)
      ly.putLabel(date_str, BLACK, WHITE, date_x, block_y + 7)
    end
  '';

  lyStartup = pkgs.writeShellScript "ly-startup" ''
    if [ "$TERM" = "linux" ]; then
      # Force pure Monosquare palette in Linux VT
      COLORS="${hex c.bg} ${hex c.red} ${hex c.green} ${hex c.yellow} ${hex c.blue} ${hex c.pink} ${hex c.accent} ${hex c.fg} ${hex c.dim} ${hex c.red} ${hex c.green} ${hex c.yellow} ${hex c.blue} ${hex c.pink} ${hex c.accent} ${hex c.fg}"
      i=0
      for col in $COLORS; do
        printf "\033]P%x%s" "$i" "$col"
        i=$(( i + 1 ))
      done
      clear
    fi
  '';
in
{
  # Display Manager
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      animation = "lua";
      lua_animation_file = "${lyAnimLua}";
      animation_frame_delay = 500;

      bigclock = "none";

      bg = lyBlack;
      fg = lyBoldWhite;
      border_fg = lyWhite;
      error_bg = lyBlack;
      error_fg = lyBoldRed;

      blank_box = true;
      hide_borders = false;
      box_position_v = 0.62;
      margin_box_h = 2;
      margin_box_v = 1;
      input_len = 34;
      text_in_center = true;
      clear_password = true;
      default_input = "password";

      # Solid square block mask (■ = U+25A0) matching hyprlock's square password dots
      asterisk = "0x25A0";

      clock = "null";
      corner_top_left = "shutdown,restart";
      corner_top_right = "capslock,numlock";
      corner_bottom_left = "";
      corner_bottom_right = "";
      edge_margin = 1;

      brightness_down_key = "null";
      brightness_up_key = "null";
      start_cmd = "${lyStartup}";
    };
  };
}
