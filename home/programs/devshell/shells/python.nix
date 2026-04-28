# Python 开发环境
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
  ];

  shellHook = ''
    echo "🐍 Python $(python3 --version) 已加载"
  '';
}
