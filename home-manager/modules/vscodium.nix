{ pkgs, ... }:

{
  programs.vscodium = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        # Themes & Icons
        miguelsolorio.fluent-icons

        # Core & Languages
        bodil.blueprint-gtk
        bradlc.vscode-tailwindcss
        jnoortheen.nix-ide
        mesonbuild.mesonbuild
        ms-python.black-formatter
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode.powershell

        # Formatters
        prettier.prettier-vscode

        # Other
        leonardssh.vscord
      ];

      userSettings = {
        # UI
        "workbench.startupEditor" = "none";
        "workbench.iconTheme" = "fluent-icons";
        "window.titleBarStyle" = "custom";
        "window.customTitleBarVisibility" = "auto";

        # Editor
        "editor.fontSize" = 16;
        "editor.fontFamily" = "JetBrainsMono Nerd Font";
        "editor.codeLensFontFamily" = "JetBrainsMono Nerd Font";
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";

        "editor.stickyScroll.enabled" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = true;
        "editor.smoothScrolling" = true;
        "workbench.list.smoothScrolling" = true;
        "terminal.integrated.smoothScrolling" = true;
        "editor.inlineSuggest.enabled" = true;

        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = false;
        "files.autoSave" = "onFocusChange";

        # Explorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.compactFolders" = false;
        "explorer.excludeGitIgnore" = true;

        # Git
        "git.autofetch" = false;
        "git.confirmSync" = false;
        "git.suggestSmartCommit" = false;
        "diffEditor.renderSideBySide" = true;
        "diffEditor.ignoreTrimWhitespace" = false;

        # Languages ​​and Formatters
        "python.languageServer" = "Pylance";

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "[css]" = {
          "editor.defaultFormatter" = "vscode.css-language-features";
        };
        "[html]" = {
          "editor.defaultFormatter" = "vscode.html-language-features";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[powershell]" = {
          "editor.defaultFormatter" = "ms-vscode.powershell";
        };

        # VSCord
        "vscord.status.image.large.debugging.key" = "https://vscord.catppuccin.com/mocha/debugging.webp";
        "vscord.status.image.large.editing.key" = "https://vscord.catppuccin.com/mocha/{lang}.webp";
        "vscord.status.image.large.idle.key" = "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
        "vscord.status.image.large.notInFile.key" =
          "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
        "vscord.status.image.large.viewing.key" = "https://vscord.catppuccin.com/mocha/{lang}.webp";
        "vscord.status.image.small.debugging.key" = "https://vscord.catppuccin.com/mocha/debugging.webp";
        "vscord.status.image.small.editing.key" = "https://vscord.catppuccin.com/mocha/{app_id}.webp";
        "vscord.status.image.small.idle.key" = "https://vscord.catppuccin.com/mocha/idle.webp";
        "vscord.status.image.small.notInFile.key" = "https://vscord.catppuccin.com/mocha/idle.webp";
        "vscord.status.image.small.viewing.key" = "https://vscord.catppuccin.com/mocha/{app_id}.webp";
      };
    };
  };

  home.packages = with pkgs; [
    nixfmt # For jnoortheen.nix-ide extension
  ];
}
