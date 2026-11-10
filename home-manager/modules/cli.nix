{
  colors,
  pkgs,
  ...
}:

let
  c = colors;
in
{
  home.packages = with pkgs; [
    just
    onefetch
    ouch-rar
    tokei
  ];

  programs = {
    bat = {
      enable = true;
      config.theme = "ansi";
    };
    fd.enable = true;
    ripgrep.enable = true;

    lazygit = {
      enable = true;
      settings = {
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
    gh.enable = true;
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
