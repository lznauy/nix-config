# Go 开发环境
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    go
    gopls
  ];

  env = {
    GOPATH = "$HOME/go";
  };

  shellHook = ''
    echo "🐹 Go $(go version | cut -d' ' -f3) 已加载"
  '';
}
