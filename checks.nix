{ pkgs }:

let
  inherit (pkgs.lib) fileset;

  nixFiles = fileset.difference (fileset.fileFilter (file: file.hasExt "nix") ./.) (
    fileset.fileFilter (file: file.name == "hardware.nix") ./.
  );

  nixSrc = fileset.toSource {
    root = ./.;
    fileset = nixFiles;
  };

  statixSrc = fileset.toSource {
    root = ./.;
    fileset = fileset.unions [
      nixFiles
      (fileset.maybeMissing ./statix.toml)
    ];
  };

  luaSrc = fileset.toSource {
    root = ./.;
    fileset = fileset.fileFilter (file: file.hasExt "lua") ./.;
  };
in
{
  format-check =
    pkgs.runCommand "format-check"
      {
        nativeBuildInputs = [ pkgs.nixfmt ];
        src = nixSrc;
      }
      ''
        find "$src" -type f -name '*.nix' -exec nixfmt --check {} +
        touch "$out"
      '';

  statix =
    pkgs.runCommand "statix-check"
      {
        nativeBuildInputs = [ pkgs.statix ];
        src = statixSrc;
      }
      ''
        statix check --config "$src" "$src"
        touch "$out"
      '';

  deadnix =
    pkgs.runCommand "deadnix-check"
      {
        nativeBuildInputs = [ pkgs.deadnix ];
        src = nixSrc;
      }
      ''
        deadnix --fail "$src"
        touch "$out"
      '';

  lua-check =
    pkgs.runCommand "lua-check"
      {
        nativeBuildInputs = [ pkgs.lua ];
        src = luaSrc;
      }
      ''
        while IFS= read -r -d "" file; do
          luac -p "$file"
        done < <(find "$src" -type f -name '*.lua' -print0)
        touch "$out"
      '';
}
