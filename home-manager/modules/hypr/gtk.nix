{ lib, ... }:
# TODO: stop depending on adw-gtk3. Ship a standalone GTK3 theme (own
# gtk-3.0/gtk.css) so this module is the theme, not a patch over another one.

let
  c = import ./colors.nix;

  # Reusable declarations
  inverted = ''
    background-color: ${c.fg};
    color: ${c.bg};
  '';
  framed = ''
    background-color: ${c.bg};
    border: 1px solid ${c.fg};
    box-shadow: none;
  '';

  # Named colors read by libadwaita and gtk3
  named = {
    accent_color = c.accent;
    accent_bg_color = c.accent;
    accent_fg_color = c.bg;

    window_bg_color = c.bg;
    window_fg_color = c.fg;
    view_bg_color = c.bg;
    view_fg_color = c.fg;

    headerbar_bg_color = c.bg;
    headerbar_fg_color = c.fg;
    headerbar_border_color = c.fg;
    headerbar_backdrop_color = c.bg;
    headerbar_shade_color = c.bg;

    card_bg_color = c.bg;
    card_fg_color = c.fg;
    card_shade_color = c.bg;

    dialog_bg_color = c.bg;
    dialog_fg_color = c.fg;

    popover_bg_color = c.bg;
    popover_fg_color = c.fg;
    popover_shade_color = c.bg;

    sidebar_bg_color = c.bg;
    sidebar_fg_color = c.fg;
    sidebar_backdrop_color = c.bg;
    sidebar_shade_color = c.bg;
    secondary_sidebar_bg_color = c.bg;
    secondary_sidebar_fg_color = c.fg;
    secondary_sidebar_backdrop_color = c.bg;
    secondary_sidebar_shade_color = c.bg;

    scrollbar_outline_color = c.fg;
    link_color = c.accent;
    visited_link_color = c.fg;
  };

  namedColors =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "@define-color ${name} ${value};") named
    )
    + "\n";

  base = ''
    * {
      border-radius: 0;
    }
  '';

  buttons = ''
    button {
      background-image: none;
      background-color: ${c.bg};
      color: ${c.fg};
      border: 1px solid ${c.fg};
      box-shadow: none;
    }
    button:hover,
    button:checked,
    button:active {
      ${inverted}
    }

    /* flat and window buttons */
    button.flat,
    button.titlebutton,
    windowcontrols button {
      background-color: transparent;
      border-color: transparent;
    }
    button.flat:hover,
    button.flat:checked,
    button.flat:active,
    button.titlebutton:hover,
    windowcontrols button:hover {
      ${inverted}
      border-color: ${c.fg};
    }
    button.titlebutton image,
    windowcontrols button image {
      background: none;
      box-shadow: none;
      color: inherit;
    }

    /* variants */
    button.suggested-action {
      background-color: ${c.accent};
      color: ${c.bg};
      border-color: ${c.accent};
    }
    button.suggested-action:hover {
      background-color: ${c.fg};
      border-color: ${c.fg};
    }
    button.destructive-action {
      color: @destructive_color;
      border-color: @destructive_color;
    }
    button.destructive-action:hover {
      background-color: @destructive_bg_color;
      color: @destructive_fg_color;
    }

    /* disabled (must stay last) */
    button:disabled,
    button:disabled:hover,
    button.suggested-action:disabled,
    button.destructive-action:disabled {
      background-color: ${c.bg};
      color: ${c.dim};
      border-color: ${c.dim};
    }
    button.flat:disabled,
    button.flat:disabled:hover,
    button.titlebutton:disabled {
      background-color: transparent;
      color: ${c.dim};
      border-color: transparent;
    }
  '';

  inputs = ''
    entry {
      ${framed}
      color: ${c.fg};
    }
    entry:disabled {
      color: ${c.dim};
      border-color: ${c.dim};
    }
  '';

  lists = ''
    selection {
      background-color: ${c.accent};
      color: ${c.bg};
    }
    row:hover,
    row:selected,
    row:selected:hover {
      ${inverted}
    }
    list.boxed-list,
    .card {
      ${framed}
    }
    list.boxed-list > row:not(:first-child) {
      border-top: 1px solid ${c.dim};
    }
  '';

  surfaces = ''
    headerbar {
      background-color: ${c.bg};
      color: ${c.fg};
      border-bottom: 1px solid ${c.fg};
      box-shadow: none;
    }
    headerbar:backdrop {
      border-bottom-color: ${c.dim};
    }

    separator {
      background-color: ${c.dim};
    }

    modelbutton:hover {
      ${inverted}
    }

    tooltip.background,
    toast {
      ${framed}
      color: ${c.fg};
    }
  '';

  controls = ''
    /* scrollbars */
    scrollbar slider {
      background-color: ${c.fg};
      border: none;
    }
    scrollbar.vertical slider {
      min-width: 4px;
    }
    scrollbar.horizontal slider {
      min-height: 4px;
    }
    scrollbar slider:hover {
      background-color: ${c.accent};
    }

    switch {
      ${framed}
    }
    switch:checked {
      background-color: ${c.accent};
      border-color: ${c.accent};
    }
    switch slider {
      background-color: ${c.fg};
      border: none;
      box-shadow: none;
    }
    switch:checked slider {
      background-color: ${c.bg};
    }

    check,
    radio {
      ${framed}
      color: ${c.bg};
    }
    check:checked,
    radio:checked,
    check:indeterminate,
    radio:indeterminate {
      background-color: ${c.accent};
      border-color: ${c.accent};
    }

    progressbar trough,
    scale trough {
      background-color: ${c.bg};
      border: 1px solid ${c.fg};
    }
    progressbar progress,
    scale highlight {
      background-color: ${c.accent};
      border: none;
    }
    scale slider {
      background-color: ${c.fg};
      border: none;
      box-shadow: none;
    }
    scale slider:hover {
      background-color: ${c.accent};
    }
  '';

  gtk3Only = ''
    decoration {
      border-radius: 0;
      box-shadow: none;
      margin: 0;
    }
    entry:focus {
      border-color: ${c.accent};
    }
    popover.background,
    menu {
      ${framed}
    }
    menuitem:hover {
      ${inverted}
    }
  '';

  gtk4Only = ''
    window.csd {
      border-radius: 0;
      box-shadow: none;
    }
    entry:focus-within {
      border-color: ${c.accent};
    }
    popover > contents,
    dialog-host sheet {
      ${framed}
    }
  '';

  nautilus = ''
    /* sidebar */
    .nautilus-window .sidebar-pane .undershoot-top {
      background-color: ${c.bg};
      border-right: 1px solid ${c.fg};
    }
    .nautilus-window placessidebar list.navigation-sidebar > row,
    .nautilus-window .navigation-sidebar > row {
      border-left: 2px solid transparent;
      padding: 6px 8px;
    }
    .nautilus-window .sidebar-pane headerbar {
      box-shadow: inset 0 -2px 0 -1px ${c.fg};
      border-bottom: none;
    }
    .nautilus-window .sidebar-pane .top-bar {
      border-right: 1px solid ${c.fg};
    }

    /* pathbar */
    #NautilusPathBar,
    .nautilus-pathbar {
      background-color: ${c.bg};
      border: 1px solid ${c.fg};
      border-radius: 0;
    }
  '';

  common = lib.concatStrings [
    namedColors
    base
    buttons
    inputs
    lists
    surfaces
    controls
  ];
in
{
  gtk.gtk3.extraCss = common + gtk3Only;
  gtk.gtk4.extraCss = common + gtk4Only + nautilus;
}
