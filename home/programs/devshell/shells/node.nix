# Node.js 开发环境
{ pkgs }:
{
  packages = with pkgs; [
    nodejs
    pnpm
    typescript
  ];

  shellHook = ''
    echo "📦 Node.js $(node --version) 已加载"
  '';
}
