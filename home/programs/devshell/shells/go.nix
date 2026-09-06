# Go 开发环境
{ pkgs }:
{
  packages = with pkgs; [
    go # 编译器
    gopls # LSP
    delve # 调试器
    golangci-lint # 代码检查
    gotests # 测试生成
    gofumpt # 格式化
    govulncheck # 漏洞检查
    air # 热重载
  ];

  shellHook = ''
    echo "🐹 Go $(go version | cut -d' ' -f3) 已加载"
  '';
}
