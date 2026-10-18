{ colors, ... }:

let
  c = colors;
in
{
  programs.superfile = {
    enable = true;
    firstUseCheck = false;

    settings = {
      theme = "rice";
      editor = "hx";
      dir_editor = "hx";
      cd_on_quit = true;
      auto_check_update = false;
      show_image_preview = true;

      ignore_missing_fields = true;

      # square borders
      border_top_left = "┌";
      border_top_right = "┐";
      border_bottom_left = "└";
      border_bottom_right = "┘";
      border_middle_left = "├";
      border_middle_right = "┤";
      border_top = "─";
      border_bottom = "─";
      border_left = "│";
      border_right = "│";
    };

    themes.rice = {
      code_syntax_highlight = "monokai";

      # borders
      file_panel_border = c.dim;
      sidebar_border = c.dim;
      footer_border = c.dim;
      file_panel_border_active = c.fg;
      sidebar_border_active = c.fg;
      footer_border_active = c.fg;
      modal_border_active = c.fg;

      # backgrounds and foregrounds
      full_screen_bg = c.bg;
      file_panel_bg = c.bg;
      sidebar_bg = c.bg;
      footer_bg = c.bg;
      modal_bg = c.bg;
      full_screen_fg = c.fg;
      file_panel_fg = c.fg;
      sidebar_fg = c.fg;
      footer_fg = c.fg;
      modal_fg = c.fg;

      # special colors
      cursor = c.fg;
      correct = c.green;
      error = c.red;
      hint = c.accent;
      cancel = c.orange;
      gradient_color = [
        c.accent
        c.fg
      ];

      # file panel
      file_panel_top_directory_icon = c.accent;
      file_panel_top_path = c.fg;
      file_panel_item_selected_fg = c.bg;
      file_panel_item_selected_bg = c.fg;

      # sidebar
      sidebar_title = c.accent;
      sidebar_item_selected_fg = c.bg;
      sidebar_item_selected_bg = c.fg;
      sidebar_divider = c.dim;

      # modals
      modal_cancel_fg = c.bg;
      modal_cancel_bg = c.mid;
      modal_confirm_fg = c.bg;
      modal_confirm_bg = c.accent;

      # help menu
      help_menu_hotkey = c.accent;
      help_menu_title = c.fg;
    };
  };

  programs.zsh.initContent = ''
    spf() {
      command superfile "$@"
      local last="''${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
      if [ -f "$last" ]; then
        source "$last"
        rm -f -- "$last"
      fi
    }
  '';
}
