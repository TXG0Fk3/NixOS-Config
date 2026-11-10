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
}
