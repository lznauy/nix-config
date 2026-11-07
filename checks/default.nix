{ pkgs, inputs }:
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
      ../home/desktop/quickshell/todo/Theme.qml
      ../home/desktop/quickshell/todo/default.nix
      ../home/desktop/quickshell/shared/Palette.js
      ../home/desktop/quickshell/dynamic-island/Common/Appearance.qml
      ../home/desktop/quickshell/dynamic-island/default.nix
      ../home/desktop/quickshell/dynamic-island/scripts/lyrics_fetcher.py
    ];
  };
  # 只使用合成口令，不读取用户的 sops 密钥；包含 shell 特殊字符验证原样传递。
  testPassword = pkgs.writeText "winapps-test-password" ''
    test-only password with "quotes" $dollars and \backslashes
  '';
  winappsModule = import ../hosts/physical/winapps.nix {
    inherit inputs pkgs lib;
    config.sops.secrets."winapps/password".path = toString testPassword;
  };
  user = import ../config/user.nix;
  winappsConfig =
    pkgs.writeText "winapps-test.conf"
      winappsModule.home-manager.users.${user.name}.xdg.configFile."winapps/winapps.conf".text;
in
{
  winapps-credentials = pkgs.runCommand "winapps-credentials-check" { } ''
    source ${winappsConfig}
    test -z "$RDP_PASS"
    test -x "$RDP_ASKPASS"
    actual=$("$RDP_ASKPASS")
    expected=$(cat ${testPassword})
    test "$actual" = "$expected"
    touch "$out"
  '';

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
