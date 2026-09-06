# Python 开发环境
{ pkgs }:
{
  packages = with pkgs; [
    python3
    python3Packages.pip
    uv
  ];

  shellHook = ''
    echo "🐍 Python $(python3 --version) 已加载"
  '';
}
