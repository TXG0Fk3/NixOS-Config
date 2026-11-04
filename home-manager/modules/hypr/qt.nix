{
  config,
  colors,
  lib,
  ...
}:

let
  c = colors;

  # qtct palettes use #AARRGGBB
  col = hex: "#ff${lib.removePrefix "#" hex}";

  # Reusable declarations
  inverted = ''
    background-color: ${c.fg};
    color: ${c.bg};
  '';
  framed = ''
    background-color: ${c.bg};
    border: 1px solid ${c.fg};
  '';
  disabled = ''
    background-color: ${c.bg};
    color: ${c.dim};
    border-color: ${c.dim};
  '';

  # QPalette roles, in the order qtct reads them
  roles = [
    "WindowText"
    "Button"
    "Light"
    "Midlight"
    "Dark"
    "Mid"
    "Text"
    "BrightText"
    "ButtonText"
    "Base"
    "Window"
    "Shadow"
    "Highlight"
    "HighlightedText"
    "Link"
    "LinkVisited"
    "AlternateBase"
    "NoRole"
    "ToolTipBase"
    "ToolTipText"
    "PlaceholderText"
  ];

  # Highlight is inverted (items, menus, QML), text selection stays accent in the stylesheet
  activeColors = {
    WindowText = c.fg;
    Button = c.bg;
    Light = c.layer3;
    Midlight = c.layer2;
    Dark = c.layer1;
    Mid = c.dim;
    Text = c.fg;
    BrightText = c.fg;
    ButtonText = c.fg;
    Base = c.bg;
    Window = c.bg;
    Shadow = c.bg;
    Highlight = c.fg;
    HighlightedText = c.bg;
    Link = c.accent;
    LinkVisited = c.fg;
    AlternateBase = c.layer1;
    NoRole = c.bg;
    ToolTipBase = c.bg;
    ToolTipText = c.fg;
    PlaceholderText = c.dim;
  };

  disabledColors = activeColors // {
    WindowText = c.dim;
    Text = c.dim;
    BrightText = c.dim;
    ButtonText = c.dim;
    Highlight = c.layer3;
    HighlightedText = c.dim;
    Link = c.dim;
    LinkVisited = c.dim;
    ToolTipText = c.dim;
  };

  row = palette: lib.concatMapStringsSep ", " (role: col palette.${role}) roles;

  scheme = ''
    [ColorScheme]
    active_colors=${row activeColors}
    inactive_colors=${row activeColors}
    disabled_colors=${row disabledColors}
  '';

  base = ''
    * {
      border-radius: 0;
      outline: none;
    }
    QWidget {
      background-color: ${c.bg};
      color: ${c.fg};
      selection-background-color: ${c.accent};
      selection-color: ${c.bg};
    }
    QWidget:disabled {
      color: ${c.dim};
    }
  '';

  buttons = ''
    QPushButton,
    QToolButton {
      ${framed}
      color: ${c.fg};
      padding: 4px 10px;
    }

    /* flat and toolbar buttons (must precede :hover) */
    QPushButton:flat,
    QToolBar QToolButton {
      border-color: transparent;
    }

    /* variants (must precede :hover) */
    QPushButton:default {
      border-color: ${c.accent};
    }

    QPushButton:hover,
    QPushButton:pressed,
    QPushButton:checked,
    QToolButton:hover,
    QToolButton:pressed,
    QToolButton:checked {
      ${inverted}
      border-color: ${c.fg};
    }

    /* disabled (must stay last) */
    QPushButton:disabled,
    QToolButton:disabled {
      ${disabled}
    }
    QPushButton:flat:disabled,
    QToolBar QToolButton:disabled {
      border-color: transparent;
    }
  '';

  inputs = ''
    QLineEdit,
    QTextEdit,
    QPlainTextEdit,
    QAbstractSpinBox,
    QComboBox {
      ${framed}
      color: ${c.fg};
      padding: 3px 6px;
    }
    QComboBox::drop-down {
      border: none;
      border-left: 1px solid ${c.fg};
      width: 18px;
    }

    /* combo boxes are buttons in gtk (must precede :focus) */
    QComboBox:!editable:hover {
      ${inverted}
    }

    QLineEdit:focus,
    QTextEdit:focus,
    QPlainTextEdit:focus,
    QAbstractSpinBox:focus,
    QComboBox:focus,
    QComboBox:on {
      border-color: ${c.accent};
    }

    /* disabled (must stay last) */
    QLineEdit:disabled,
    QTextEdit:disabled,
    QPlainTextEdit:disabled,
    QAbstractSpinBox:disabled,
    QComboBox:disabled {
      ${disabled}
    }
  '';

  lists = ''
    QAbstractItemView,
    QTreeView,
    QListView,
    QTableView {
      ${framed}
      alternate-background-color: ${c.layer1};
      selection-background-color: ${c.fg};
      selection-color: ${c.bg};
      show-decoration-selected: 1;
    }
    QTreeView::item:hover,
    QTreeView::item:selected,
    QListView::item:hover,
    QListView::item:selected,
    QTableView::item:hover,
    QTableView::item:selected {
      ${inverted}
    }

    /* headers */
    QHeaderView::section,
    QTableCornerButton::section {
      background-color: ${c.bg};
      color: ${c.fg};
      border: 1px solid ${c.dim};
      border-bottom: 1px solid ${c.fg};
      padding: 2px 6px;
    }
    QHeaderView::section:hover,
    QHeaderView::section:pressed,
    QHeaderView::section:checked {
      ${inverted}
    }
  '';

  surfaces = ''
    QToolTip {
      ${framed}
      color: ${c.fg};
      padding: 2px 4px;
    }

    /* menus */
    QMenuBar {
      background-color: ${c.bg};
      border-bottom: 1px solid ${c.fg};
    }
    QMenuBar::item {
      background-color: transparent;
      padding: 4px 10px;
    }
    QMenuBar::item:selected,
    QMenuBar::item:pressed {
      ${inverted}
    }
    QMenu {
      ${framed}
      padding: 2px;
    }
    QMenu::item {
      padding: 4px 20px;
    }
    QMenu::item:selected {
      ${inverted}
    }
    QMenu::item:disabled {
      color: ${c.dim};
    }
    QMenu::separator {
      height: 1px;
      background-color: ${c.dim};
      margin: 2px 0;
    }

    /* tabs */
    QTabWidget::pane {
      border: 1px solid ${c.fg};
    }
    QTabBar::tab {
      background-color: ${c.bg};
      color: ${c.dim};
      border: 1px solid ${c.dim};
      padding: 4px 10px;
      margin-right: 2px;
    }
    QTabBar::tab:hover {
      color: ${c.fg};
      border-color: ${c.fg};
    }
    QTabBar::tab:selected {
      ${inverted}
      border-color: ${c.fg};
    }

    /* bars and panels */
    QToolBar {
      border: none;
      border-bottom: 1px solid ${c.fg};
      spacing: 4px;
    }
    QStatusBar {
      border-top: 1px solid ${c.fg};
    }
    QDockWidget::title {
      ${framed}
      padding: 4px;
    }
    QGroupBox {
      border: 1px solid ${c.dim};
      margin-top: 8px;
      padding-top: 6px;
    }
    QGroupBox::title {
      subcontrol-origin: margin;
      left: 8px;
      padding: 0 4px;
    }
    QSplitter::handle {
      background-color: ${c.dim};
    }
  '';

  controls = ''
    /* scrollbars */
    QScrollBar:vertical {
      background-color: ${c.bg};
      width: 8px;
      margin: 0;
    }
    QScrollBar:horizontal {
      background-color: ${c.bg};
      height: 8px;
      margin: 0;
    }
    QScrollBar::handle:vertical {
      background-color: ${c.fg};
      min-height: 24px;
    }
    QScrollBar::handle:horizontal {
      background-color: ${c.fg};
      min-width: 24px;
    }
    QScrollBar::handle:hover {
      background-color: ${c.accent};
    }
    QScrollBar::add-line,
    QScrollBar::sub-line {
      width: 0;
      height: 0;
      background: none;
    }
    QScrollBar::add-page,
    QScrollBar::sub-page {
      background: none;
    }

    /* checks and radios */
    QCheckBox::indicator,
    QRadioButton::indicator {
      ${framed}
      width: 12px;
      height: 12px;
    }
    QCheckBox::indicator:checked,
    QRadioButton::indicator:checked {
      background-color: ${c.accent};
      border-color: ${c.accent};
    }
    QCheckBox::indicator:disabled,
    QRadioButton::indicator:disabled {
      ${disabled}
    }

    /* progress and sliders */
    QProgressBar {
      ${framed}
      text-align: center;
    }
    QProgressBar::chunk {
      background-color: ${c.accent};
    }
    QSlider::groove:horizontal {
      height: 4px;
      background-color: ${c.dim};
    }
    QSlider::sub-page:horizontal {
      background-color: ${c.accent};
    }
    QSlider::handle:horizontal {
      width: 10px;
      margin: -5px 0;
      background-color: ${c.fg};
    }
    QSlider::groove:vertical {
      width: 4px;
      background-color: ${c.dim};
    }
    QSlider::add-page:vertical {
      background-color: ${c.accent};
    }
    QSlider::handle:vertical {
      height: 10px;
      margin: 0 -5px;
      background-color: ${c.fg};
    }
    QSlider::handle:hover {
      background-color: ${c.accent};
    }
    QSlider::handle:disabled {
      background-color: ${c.dim};
    }
  '';

  stylesheet = lib.concatStrings [
    base
    buttons
    inputs
    lists
    surfaces
    controls
  ];

  settings = ver: {
    Appearance = {
      style = "Fusion";
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/qt${ver}ct/colors/monosquare.conf";
      icon_theme = "Hatter-Slate";
      standard_dialog = "default";
    };
    Fonts = {
      general = "JetBrainsMono Nerd Font,10";
      fixed = "JetBrainsMono Nerd Font,10";
    };
    Interface = {
      stylesheets = "${config.xdg.configHome}/qt${ver}ct/qss/monosquare.qss";
    };
  };
in
{
  qt.qt5ctSettings = settings "5";
  qt.qt6ctSettings = settings "6";

  xdg.configFile = {
    "qt5ct/colors/monosquare.conf".text = scheme;
    "qt6ct/colors/monosquare.conf".text = scheme;
    "qt5ct/qss/monosquare.qss".text = stylesheet;
    "qt6ct/qss/monosquare.qss".text = stylesheet;
  };
}
