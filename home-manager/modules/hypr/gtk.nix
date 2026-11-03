{
  colors,
  lib,
  ...
}:

let
  c = colors;

  # Reusable declarations
  inverted = ''
    background-color: ${c.fg};
    color: ${c.bg};
  '';
  framed = ''
    background-color: ${c.bg};
    background-image: none;
    border: 1px solid ${c.fg};
    box-shadow: none;
  '';
  disabled = ''
    background-color: ${c.bg};
    color: ${c.dim};
    border-color: ${c.dim};
  '';

  # Named colors read by libadwaita and gtk3
  named = {
    accent_color = c.accent;
    accent_bg_color = c.accent;
    accent_fg_color = c.bg;

    destructive_color = c.red;
    destructive_bg_color = c.red;
    destructive_fg_color = c.bg;

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

    theme_bg_color = c.bg;
    theme_fg_color = c.fg;
    theme_base_color = c.bg;
    theme_text_color = c.fg;
    theme_selected_bg_color = c.accent;
    theme_selected_fg_color = c.bg;
    insensitive_bg_color = c.bg;
    insensitive_fg_color = c.dim;
    insensitive_base_color = c.bg;
    theme_unfocused_bg_color = c.bg;
    theme_unfocused_fg_color = c.dim;
    theme_unfocused_base_color = c.bg;
    theme_unfocused_text_color = c.dim;
    borders = c.fg;
    unfocused_borders = c.dim;
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
    *:link,
    button.link {
      color: ${c.accent};
    }
    *:visited {
      color: ${c.fg};
    }
  '';

  buttons = ''
    button {
      ${framed}
      color: ${c.fg};
    }

    /* flat and window buttons (must precede :hover) */
    button.flat,
    button.titlebutton,
    windowcontrols button {
      background-color: transparent;
      border-color: transparent;
    }
    button.titlebutton image,
    windowcontrols button image {
      background: none;
      box-shadow: none;
      color: inherit;
    }

    button:hover,
    button:checked,
    button:active {
      ${inverted}
      border-color: ${c.fg};
    }

    /* variants */
    button.suggested-action {
      background-color: ${c.accent};
      color: ${c.bg};
      border-color: ${c.accent};
    }
    button.suggested-action:hover,
    button.suggested-action:active {
      background-color: ${c.fg};
      color: ${c.bg};
      border-color: ${c.fg};
    }
    button.destructive-action {
      color: ${c.red};
      border-color: ${c.red};
    }
    button.destructive-action:hover,
    button.destructive-action:active {
      background-color: ${c.red};
      color: ${c.bg};
      border-color: ${c.red};
    }

    /* disabled (must stay last) */
    button:disabled,
    button.suggested-action:disabled,
    button.destructive-action:disabled {
      ${disabled}
    }
    button.flat:disabled,
    button.titlebutton:disabled,
    windowcontrols button:disabled {
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
      ${disabled}
    }
  '';

  lists = ''
    selection {
      background-color: ${c.accent};
      color: ${c.bg};
    }
    rubberband,
    .rubberband {
      background-color: transparent;
      border: 1px solid ${c.accent};
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
      background-image: none;
      color: ${c.fg};
      border-bottom: 1px solid ${c.fg};
      box-shadow: none;
    }
    headerbar:backdrop {
      border-bottom-color: ${c.dim};
    }

    separator {
      background-color: ${c.dim};
      background-image: none;
    }

    modelbutton:hover {
      ${inverted}
    }
    modelbutton:disabled {
      color: ${c.dim};
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

    /* switches */
    switch {
      ${framed}
    }
    switch:checked {
      background-color: ${c.accent};
      border-color: ${c.accent};
    }
    switch:disabled {
      border-color: ${c.dim};
    }
    switch slider {
      background-color: ${c.fg};
      background-image: none;
      border: none;
      box-shadow: none;
    }
    switch:checked slider {
      background-color: ${c.bg};
    }
    switch:disabled slider {
      background-color: ${c.dim};
    }

    /* checks and radios */
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
      color: ${c.bg};
    }
    check:disabled,
    radio:disabled {
      ${disabled}
    }

    /* progress, levels and scales */
    progressbar trough,
    scale trough,
    levelbar trough {
      ${framed}
    }
    progressbar progress,
    scale highlight {
      background-color: ${c.accent};
      background-image: none;
      border: none;
    }
    scale slider {
      background-color: ${c.fg};
      background-image: none;
      border: none;
      box-shadow: none;
    }
    scale slider:hover {
      background-color: ${c.accent};
    }
    scale slider:disabled {
      background-color: ${c.dim};
    }
  '';

  gtk3Only = ''
    * {
      text-shadow: none;
      -gtk-icon-shadow: none;
      -gtk-outline-radius: 0;
    }

    /* surfaces */
    .background,
    .view,
    .view text,
    textview text,
    textview border,
    iconview,
    treeview.view,
    list,
    .sidebar,
    placessidebar,
    notebook > header,
    notebook > stack,
    toolbar,
    .inline-toolbar,
    .location-bar,
    searchbar > revealer > box,
    actionbar > revealer > box,
    menubar,
    .menubar,
    statusbar {
      background-color: ${c.bg};
      background-image: none;
      color: ${c.fg};
      box-shadow: none;
    }
    .sidebar,
    stacksidebar list,
    .inline-toolbar,
    .location-bar,
    searchbar > revealer > box,
    actionbar > revealer > box,
    filechooser .dialog-action-box,
    filechooser #pathbarbox {
      border-color: ${c.fg};
    }
    .view:selected,
    iconview:selected,
    treeview.view:selected,
    flowbox flowboxchild:selected {
      ${inverted}
    }

    /* window decorations and titlebars */
    decoration,
    .csd decoration,
    .ssd decoration,
    .solid-csd decoration {
      box-shadow: none;
      margin: 0;
      padding: 0;
      border: none;
    }
    .titlebar:not(headerbar) {
      background-color: ${c.bg};
      background-image: none;
      color: ${c.fg};
      box-shadow: none;
      border-bottom: 1px solid ${c.fg};
    }
    .titlebar:backdrop:not(headerbar) {
      border-bottom-color: ${c.dim};
    }
    window.csd > .titlebar:not(headerbar) {
      border-style: none;
    }
    button.titlebutton {
      min-width: 24px;
      min-height: 24px;
      padding: 0;
      margin: 0 2px;
    }

    /* spinbuttons and entries */
    entry:focus,
    spinbutton:not(.vertical):focus {
      border-color: ${c.accent};
    }
    spinbutton:not(.vertical) {
      ${framed}
      color: ${c.fg};
      padding: 0;
    }
    spinbutton:not(.vertical):disabled {
      ${disabled}
    }
    spinbutton:not(.vertical) entry {
      border: none;
      background-color: transparent;
      box-shadow: none;
    }
    spinbutton:not(.vertical) button {
      border-width: 0 0 0 1px;
      border-style: solid;
      border-color: ${c.fg};
    }

    /* notebooks */
    notebook > header {
      border-color: ${c.fg};
      padding: 2px;
    }
    notebook > header tabs {
      margin: 0;
    }
    notebook > header > tabs > tab {
      background-color: ${c.bg};
      color: ${c.dim};
      border: 1px solid ${c.dim};
      box-shadow: none;
      margin: 0 1px;
      padding: 4px 10px;
      min-height: 20px;
    }
    notebook > header > tabs > tab:hover {
      color: ${c.fg};
      border-color: ${c.fg};
    }
    notebook > header > tabs > tab:checked {
      ${inverted}
      border-color: ${c.fg};
    }

    /* lists and treeviews */
    row {
      padding-top: 4px;
      padding-bottom: 4px;
    }
    filechooser placessidebar list {
      padding: 4px 6px;
    }
    treeview.view header button {
      border-width: 0 1px 1px 0;
      border-style: solid;
      border-color: ${c.dim};
      border-bottom-color: ${c.fg};
      padding: 2px 6px;
    }

    /* frames and separators */
    frame > border,
    .frame {
      border-color: ${c.fg};
    }
    paned > separator {
      background-color: transparent;
      background-image: image(${c.dim});
    }
    paned > separator.wide {
      background-color: ${c.bg};
      background-image: image(${c.dim}), image(${c.dim});
    }

    /* menus */
    popover.background,
    menu,
    .menu,
    .context-menu {
      ${framed}
      color: ${c.fg};
    }
    menuitem {
      color: ${c.fg};
      background-color: transparent;
      box-shadow: none;
    }
    menuitem:hover {
      ${inverted}
    }
    menuitem:disabled {
      color: ${c.dim};
    }

    /* scrolled windows */
    scrolledwindow overshoot,
    scrolledwindow undershoot {
      background-image: none;
      background-color: transparent;
    }
    scrolledwindow junction {
      border-image: none;
      background-color: ${c.bg};
    }
    scrollbar {
      background-color: ${c.bg};
      background-image: none;
      border-color: ${c.dim};
    }
    scrollbar slider {
      margin: 0;
    }

    /* switches */
    switch {
      color: transparent;
    }
    switch slider {
      margin: 0;
      min-width: 22px;
      min-height: 22px;
    }

    /* progress, levels and scales */
    progressbar.horizontal trough,
    progressbar.horizontal progress {
      min-height: 6px;
    }
    progressbar.vertical trough,
    progressbar.vertical progress {
      min-width: 6px;
    }
    progressbar progress,
    scale highlight,
    scale fill {
      margin: 0;
    }
    scale fill {
      background-color: ${c.dim};
      border: none;
    }
    scale slider {
      min-width: 14px;
      min-height: 14px;
      margin: -6px;
    }
    levelbar block:not(.empty) {
      background-color: ${c.accent};
      border-color: ${c.accent};
    }
    levelbar block.empty {
      border-color: ${c.dim};
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
