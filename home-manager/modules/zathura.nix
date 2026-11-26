{ colors, ... }:

let
  c = colors;
in
{
  programs.zathura = {
    enable = true;

    options = {
      font = "JetBrainsMono Nerd Font 10";
      guioptions = "s";
      selection-clipboard = "clipboard";
      adjust-open = "width";
      window-title-basename = true;
      statusbar-home-tilde = true;
      incremental-search = true;
      scroll-step = 60;
      zoom-step = 10;

      # Monosquare theme
      default-bg = c.bg;
      default-fg = c.fg;
      statusbar-bg = c.bg;
      statusbar-fg = c.fg;
      inputbar-bg = c.bg;
      inputbar-fg = c.fg;
      notification-bg = c.bg;
      notification-fg = c.fg;
      notification-error-bg = c.bg;
      notification-error-fg = c.red;
      notification-warning-bg = c.bg;
      notification-warning-fg = c.yellow;
      completion-bg = c.bg;
      completion-fg = c.fg;
      completion-group-bg = c.layer1;
      completion-group-fg = c.mid;
      completion-highlight-bg = c.fg;
      completion-highlight-fg = c.bg;
      index-bg = c.bg;
      index-fg = c.fg;
      index-active-bg = c.fg;
      index-active-fg = c.bg;
      highlight-color = "${c.accent}59";
      highlight-active-color = "${c.fg}80";
      render-loading-bg = c.bg;
      render-loading-fg = c.fg;

      # Dark mode recolor (toggle with 'i' or Ctrl+R)
      recolor = true;
      recolor-keephue = true;
      recolor-darkcolor = c.fg;
      recolor-lightcolor = c.bg;
    };

    mappings = {
      u = "scroll half-up";
      d = "scroll half-down";
      D = "toggle_page_mode";
      r = "reload";
      R = "rotate";
      K = "zoom in";
      J = "zoom out";
      i = "recolor";
      p = "print";
    };
  };
}
