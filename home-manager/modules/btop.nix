{ colors, ... }:

let
  c = colors;
in
{
  programs.btop = {
    enable = true;

    settings = {
      color_theme = "monosquare";
      theme_background = false;
      rounded_corners = false;
      vim_keys = true;
      graph_symbol = "braille";
    };

    themes.monosquare = ''
      # Main background, empty for terminal default
      theme[main_bg]="${c.bg}"

      # Main text color
      theme[main_fg]="${c.fg}"

      # Title color for boxes
      theme[title]="${c.fg}"

      # Highlight color for keyboard shortcuts
      theme[hi_fg]="${c.accent}"

      # Background color of selected item in processes box
      theme[selected_bg]="${c.layer2}"

      # Foreground color of selected item in processes box
      theme[selected_fg]="${c.fg}"

      # Color of inactive/disabled text
      theme[inactive_fg]="${c.dim}"

      # Misc colors for processes box
      theme[proc_misc]="${c.mid}"

      # Box outline colors
      theme[cpu_box]="${c.dim}"
      theme[mem_box]="${c.dim}"
      theme[net_box]="${c.dim}"
      theme[proc_box]="${c.dim}"

      # Box divider line and small boxes line color
      theme[div_line]="${c.layer2}"

      # Temperature graph colors
      theme[temp_start]="${c.green}"
      theme[temp_mid]="${c.yellow}"
      theme[temp_end]="${c.red}"

      # CPU graph colors
      theme[cpu_start]="${c.accent}"
      theme[cpu_mid]="${c.yellow}"
      theme[cpu_end]="${c.red}"

      # Mem/Disk free meter
      theme[free_start]="${c.dim}"
      theme[free_mid]="${c.mid}"
      theme[free_end]="${c.blue}"

      # Mem/Disk cached meter
      theme[cached_start]="${c.layer3}"
      theme[cached_mid]="${c.dim}"
      theme[cached_end]="${c.mid}"

      # Mem/Disk available meter
      theme[available_start]="${c.dim}"
      theme[available_mid]="${c.blue}"
      theme[available_end]="${c.accent}"

      # Mem/Disk used meter
      theme[used_start]="${c.green}"
      theme[used_mid]="${c.yellow}"
      theme[used_end]="${c.red}"

      # Download graph colors
      theme[download_start]="${c.dim}"
      theme[download_mid]="${c.blue}"
      theme[download_end]="${c.accent}"

      # Upload graph colors
      theme[upload_start]="${c.dim}"
      theme[upload_mid]="${c.pink}"
      theme[upload_end]="${c.yellow}"

      # Process meter
      theme[process_start]="${c.green}"
      theme[process_mid]="${c.yellow}"
      theme[process_end]="${c.red}"
    '';
  };
}
