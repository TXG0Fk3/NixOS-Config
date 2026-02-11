{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      
      extensions = with pkgs.vscode-extensions; [
        bodil.blueprint-gtk
        bradlc.vscode-tailwindcss
        jnoortheen.nix-ide
        leonardssh.vscord
        mesonbuild.mesonbuild
        ms-python.python
        ms-vscode.powershell
        piousdeer.adwaita-theme
      ];
      userSettings = {
        "workbench.startupEditor" = "none";
        "workbench.colorTheme" = "Adwaita Dark";
        "window.titleBarStyle" = "custom";
        "window.customTitleBarVisibility" = "auto";
        "editor.fontSize" = 16;
        
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";

        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.compactFolders" = false;

        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.suggestSmartCommit" = false;

        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "files.autoSave" = "afterDelay";
        "security.workspace.trust.untrustedFiles" = "open";

        "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
        "[css]" = { "editor.defaultFormatter" = "vscode.css-language-features"; };
        "[html]" = { "editor.defaultFormatter" = "vscode.html-language-features"; };
        "[powershell]" = { "editor.defaultFormatter" = "ms-vscode.powershell"; };

        "vscord.status.image.large.debugging.key" = "https://vscord.catppuccin.com/mocha/debugging.webp";
        "vscord.status.image.large.editing.key" = "https://vscord.catppuccin.com/mocha/{lang}.webp";
        "vscord.status.image.large.idle.key" = "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
        "vscord.status.image.large.notInFile.key" = "https://vscord.catppuccin.com/mocha/idle-{app_id}.webp";
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