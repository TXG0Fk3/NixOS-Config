{
  colors,
  pkgs,
  ...
}:

let
  c = colors;

  mkTmRule =
    name: scope: settings:
    let
      entries = builtins.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (k: v: "        <key>${k}</key><string>${v}</string>") settings
      );
    in
    ''
      <dict>
        <key>name</key><string>${name}</string>
        <key>scope</key><string>${scope}</string>
        <key>settings</key>
        <dict>
      ${entries}
        </dict>
      </dict>
    '';

  monosquareTheme = pkgs.writeText "monosquare.tmTheme" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>name</key><string>monosquare</string>
      <key>settings</key>
      <array>
        <dict>
          <key>settings</key>
          <dict>
            <key>background</key><string>${c.bg}</string>
            <key>foreground</key><string>${c.fg}</string>
            <key>caret</key><string>${c.fg}</string>
            <key>selection</key><string>${c.layer2}</string>
            <key>lineHighlight</key><string>${c.layer1}</string>
          </dict>
        </dict>
        ${mkTmRule "Comment" "comment, punctuation.definition.comment" {
          foreground = c.dim;
          fontStyle = "italic";
        }}
        ${mkTmRule "Keyword"
          "keyword, storage.type, storage.modifier, variable.language, entity.name.tag, meta.tag"
          {
            foreground = c.pink;
          }
        }
        ${mkTmRule "Operator and Punctuation" "keyword.operator, punctuation" {
          foreground = c.mid;
        }}
        ${mkTmRule "String" "string, markup.inline.raw" {
          foreground = c.green;
        }}
        ${mkTmRule "Constant"
          "constant.numeric, constant.language, constant.character, constant.other, markup.list"
          {
            foreground = c.orange;
          }
        }
        ${mkTmRule "Type and Attribute"
          "entity.name.type, entity.name.class, entity.name.struct, support.type, entity.other.attribute-name"
          {
            foreground = c.yellow;
          }
        }
        ${mkTmRule "Function" "entity.name.function, support.function, markup.underline.link" {
          foreground = c.blue;
        }}
        ${mkTmRule "Variable" "variable, variable.other" {
          foreground = c.fg;
        }}
        ${mkTmRule "Parameter" "variable.parameter" {
          foreground = c.fg;
          fontStyle = "italic";
        }}
        ${mkTmRule "Heading" "markup.heading" {
          foreground = c.pink;
          fontStyle = "bold";
        }}
        ${mkTmRule "Quote" "markup.quote" {
          foreground = c.mid;
          fontStyle = "italic";
        }}
      </array>
    </dict>
    </plist>
  '';
in
{
  home.packages = with pkgs; [
    curlie
    jq
    just
    onefetch
    ouch-rar
    tokei
  ];

  programs = {
    bat = {
      enable = true;
      config.theme = "monosquare";
      themes.monosquare.src = monosquareTheme;
    };
    fd.enable = true;
    ripgrep.enable = true;

    lazygit = {
      enable = true;
      settings = {
        git.diffRenderers = [
          {
            name = "delta";
            colorArg = "always";
            command = "delta --paging=never";
          }
        ];
        gui = {
          border = "single";
          theme = {
            activeBorderColor = [
              c.fg
              "bold"
            ];
            inactiveBorderColor = [ c.dim ];
            searchingActiveBorderColor = [
              c.yellow
              "bold"
            ];
            optionsTextColor = [ c.mid ];
            selectedLineBgColor = [ c.layer2 ];
            inactiveViewSelectedLineBgColor = [ c.layer1 ];
            cherryPickedCommitBgColor = [ c.layer2 ];
            cherryPickedCommitFgColor = [ c.blue ];
            markedBaseCommitBgColor = [ c.layer2 ];
            markedBaseCommitFgColor = [ c.yellow ];
            unstagedChangesColor = [ c.red ];
            defaultFgColor = [ c.fg ];
          };
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidget = {
        command = "fd --type f --hidden --exclude .git";
        options = [ "--preview 'bat --color=always --style=numbers {}'" ];
      };
      changeDirWidget = {
        command = "fd --type d --hidden --exclude .git";
        options = [ "--preview 'eza --tree --level=2 --color=always {}'" ];
      };
      defaultOptions = [
        "--border=sharp"
      ];
      colors = {
        bg = c.bg;
        "bg+" = c.layer2;
        fg = c.fg;
        "fg+" = c.fg;
        hl = c.accent;
        "hl+" = c.accent;
        info = c.mid;
        marker = c.fg;
        prompt = c.fg;
        pointer = c.fg;
        spinner = c.mid;
        header = c.dim;
        border = c.dim;
        "preview-border" = c.dim;
        label = c.fg;
        query = c.fg;
      };
    };

    posting = {
      enable = true;
      package = pkgs.posting.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/posting/posting.scss \
            --replace-fail "border: round" "border: solid"
        '';
      });
      settings = {
        theme = "monosquare";
      };
      themes.monosquare = {
        name = "monosquare";
        nerd_fonts = true;
        primary = c.fg;
        secondary = c.dim;
        accent = c.fg;
        background = c.bg;
        surface = c.layer1;
        panel = c.layer2;
        success = c.green;
        warning = c.yellow;
        error = c.red;
        text_area = {
          cursor = c.fg;
          cursor_line = c.layer1;
          selection = c.layer2;
        };
        method = {
          get = c.blue;
          post = c.green;
          put = c.yellow;
          delete = c.red;
          patch = c.accent;
          options = c.pink;
          head = c.orange;
        };
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };
    zellij = {
      enable = true;
      enableZshIntegration = false;
    };
    git.enable = true;
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "monosquare";
        file-style = "${c.fg} bold";
        file-decoration-style = "${c.dim} box";
        hunk-header-decoration-style = "${c.layer3} box";
        minus-style = "syntax ${c.redDark}";
        minus-emph-style = "syntax ${c.redEmph} bold";
        plus-style = "syntax ${c.greenDark}";
        plus-emph-style = "syntax ${c.greenEmph} bold";
        line-numbers-minus-style = c.red;
        line-numbers-plus-style = c.green;
        line-numbers-zero-style = c.dim;
        line-numbers-left-style = c.layer3;
        line-numbers-right-style = c.layer3;
      };
    };
    gh.enable = true;
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
