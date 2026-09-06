{ pkgs }:
let
  inherit (pkgs) lib;
  nixSource = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (file: file.hasExt "nix") ../.)
      ../statix.toml
    ];
  };
  testSource = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../tests
      ../home/programs/onlyoffice-fonts.sh
      ../home/desktop/quickshell/todo/TodoModel.js
      ../home/desktop/quickshell/shared/Palette.js
      ../home/desktop/quickshell/dynamic-island/scripts/lyrics_fetcher.py
    ];
  };
in
{
  nix =
    pkgs.runCommand "nix-config-lint"
      {
        nativeBuildInputs = with pkgs; [
          nixfmt
          statix
          deadnix
        ];
      }
      ''
        cd ${nixSource}
        find . -name '*.nix' -print0 | xargs -0 nixfmt --check
        statix check .
        deadnix --fail .
        touch "$out"
      '';

  tests =
    pkgs.runCommand "nix-config-tests"
      {
        nativeBuildInputs = with pkgs; [
          nodejs
          python3
        ];
      }
      ''
        cd ${testSource}
        node --test tests/*.test.cjs
        PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py'
        touch "$out"
      '';
}
