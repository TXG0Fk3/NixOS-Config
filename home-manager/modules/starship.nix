{ colors, ... }:

let
  c = colors;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      palette = "mono";
      add_newline = false;

      format = ''
        $os$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character
      '';

      os = {
        disabled = false;
        format = "[$symbol]($style) ";
        style = "bold white";
        symbols = {
          NixOS = " ";
        };
      };

      directory = {
        style = "bold white";
        truncation_length = 3;
        truncation_symbol = "…/";
        format = "[$path]($style) ";
      };

      git_branch = {
        style = "white";
        format = "[$symbol$branch]($style) ";
        symbol = "git:";
      };

      git_status = {
        style = "cyan";
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "≡";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      nix_shell = {
        style = "cyan";
        format = "[$symbol$state( ($name))]($style) ";
        symbol = "nix:";
      };

      cmd_duration = {
        min_time = 2000;
        style = "gray";
        format = "[$duration]($style) ";
      };

      character = {
        success_symbol = "[❯](bold white)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold white)";
      };

      palettes.mono = {
        white = c.fg;
        black = c.bg;
        gray = c.dim;

        blue = c.blue;
        green = c.green;
        red = c.red;
        yellow = c.yellow;
        purple = c.pink;
        cyan = c.accent;
        orange = c.orange;
      };
    };
  };
}
