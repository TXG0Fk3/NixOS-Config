{ colors, pkgs, ... }:

let
  c = colors;

  prettierFormatter = parser: {
    command = "prettier";
    args = [
      "--parser"
      parser
    ];
  };
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      # Go
      gopls
      delve

      # C#
      omnisharp-roslyn
      netcoredbg

      # TypeScript / web
      typescript-language-server
      vscode-langservers-extracted
      prettier

      # Nix
      nil
      nixfmt

      # Misc
      lua-language-server
      marksman
      taplo
      yaml-language-server
      bash-language-server
    ];

    settings = {
      theme = "rice";

      editor = {
        cursorline = true;
        color-modes = true;
        bufferline = "multiple";
        popup-border = "all";
        scrolloff = 8;
        idle-timeout = 100;
        completion-trigger-len = 1;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        indent-guides = {
          render = true;
          character = "│";
          skip-levels = 1;
        };

        lsp.display-inlay-hints = true;
        file-picker.hidden = false;

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "version-control"
          ];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };

      keys = {
        normal = {
          C-s = ":write";
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
        insert.C-s = ":write";
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "nixfmt";
      }
      {
        name = "go";
        auto-format = true;
      }
      {
        name = "markdown";
        soft-wrap.enable = true;
      }
      {
        name = "typescript";
        formatter = prettierFormatter "typescript";
      }
      {
        name = "tsx";
        formatter = prettierFormatter "typescript";
      }
      {
        name = "javascript";
        formatter = prettierFormatter "babel";
      }
      {
        name = "jsx";
        formatter = prettierFormatter "babel";
      }
    ];

    themes.rice = {
      # base
      "ui.background".bg = c.bg;
      "ui.text".fg = c.fg;
      "ui.text.focus" = {
        modifiers = [
          "reversed"
          "bold"
        ];
      };
      "ui.text.directory" = {
        fg = c.blue;
        modifiers = [ "bold" ];
      };
      "ui.text.symlink".fg = c.accent;
      "ui.text.inactive".fg = c.dim;
      "ui.text.info".fg = c.accent;

      # cursor and selection
      "ui.cursor" = {
        fg = c.bg;
        bg = c.mid;
      };
      "ui.cursor.primary" = {
        fg = c.bg;
        bg = c.fg;
      };
      "ui.cursor.match" = {
        fg = c.accent;
        modifiers = [
          "bold"
          "underlined"
        ];
      };
      "ui.selection".bg = c.layer2;
      "ui.selection.primary".bg = c.layer3;
      "ui.cursorline.primary".bg = c.layer1;

      # gutter
      "ui.linenr".fg = c.dim;
      "ui.linenr.selected" = {
        fg = c.fg;
        modifiers = [ "bold" ];
      };

      # statusline
      "ui.statusline" = {
        fg = c.fg;
        bg = c.layer1;
      };
      "ui.statusline.inactive" = {
        fg = c.dim;
        bg = c.layer1;
      };
      "ui.statusline.normal" = {
        fg = c.bg;
        bg = c.fg;
        modifiers = [ "bold" ];
      };
      "ui.statusline.insert" = {
        fg = c.bg;
        bg = c.accent;
        modifiers = [ "bold" ];
      };
      "ui.statusline.select" = {
        fg = c.bg;
        bg = c.mid;
        modifiers = [ "bold" ];
      };

      # bufferline
      "ui.bufferline" = {
        fg = c.mid;
        bg = c.layer1;
      };
      "ui.bufferline.active" = {
        fg = c.bg;
        bg = c.fg;
        modifiers = [ "bold" ];
      };
      "ui.bufferline.background".bg = c.layer1;

      # popups and menus
      "ui.popup" = {
        fg = c.fg;
        bg = c.bg;
      };
      "ui.popup.info" = {
        fg = c.fg;
        bg = c.bg;
      };
      "ui.window".fg = c.fg;
      "ui.help" = {
        fg = c.fg;
        bg = c.bg;
      };
      "ui.menu" = {
        fg = c.fg;
        bg = c.bg;
      };
      "ui.menu.selected" = {
        fg = c.bg;
        bg = c.fg;
      };
      "ui.menu.scroll" = {
        fg = c.mid;
        bg = c.layer1;
      };

      # virtual elements
      "ui.virtual.ruler".bg = c.layer1;
      "ui.virtual.whitespace".fg = c.layer3;
      "ui.virtual.indent-guide".fg = c.layer2;
      "ui.virtual.inlay-hint".fg = c.dim;
      "ui.virtual.jump-label" = {
        fg = c.accent;
        modifiers = [ "bold" ];
      };

      # diagnostics
      "error".fg = c.red;
      "warning".fg = c.yellow;
      "info".fg = c.accent;
      "hint".fg = c.dim;
      "diagnostic.error".underline = {
        color = c.red;
        style = "curl";
      };
      "diagnostic.warning".underline = {
        color = c.yellow;
        style = "curl";
      };
      "diagnostic.info".underline = {
        color = c.accent;
        style = "dotted";
      };
      "diagnostic.hint".underline = {
        color = c.dim;
        style = "dotted";
      };
      "diagnostic.unnecessary".modifiers = [ "dim" ];
      "diagnostic.deprecated".modifiers = [ "crossed_out" ];

      # syntax
      "comment" = {
        fg = c.dim;
        modifiers = [ "italic" ];
      };
      "keyword".fg = c.pink;
      "operator".fg = c.mid;
      "punctuation".fg = c.mid;
      "string".fg = c.green;
      "constant".fg = c.orange;
      "type".fg = c.yellow;
      "function".fg = c.blue;
      "function.macro".fg = c.pink;
      "variable".fg = c.fg;
      "variable.builtin" = {
        fg = c.pink;
        modifiers = [ "italic" ];
      };
      "variable.parameter" = {
        fg = c.fg;
        modifiers = [ "italic" ];
      };
      "attribute" = {
        fg = c.yellow;
        modifiers = [ "italic" ];
      };
      "namespace".fg = c.fg;
      "label".fg = c.pink;
      "tag".fg = c.pink;

      # markup
      "markup.heading" = {
        fg = c.pink;
        modifiers = [ "bold" ];
      };
      "markup.bold".modifiers = [ "bold" ];
      "markup.italic".modifiers = [ "italic" ];
      "markup.strikethrough".modifiers = [ "crossed_out" ];
      "markup.link.url" = {
        fg = c.accent;
        modifiers = [ "underlined" ];
      };
      "markup.link.text".fg = c.blue;
      "markup.quote" = {
        fg = c.mid;
        modifiers = [ "italic" ];
      };
      "markup.raw".fg = c.green;
      "markup.list".fg = c.orange;

      # git gutter
      "diff.plus".fg = c.green;
      "diff.delta".fg = c.yellow;
      "diff.minus".fg = c.red;
    };
  };
}
