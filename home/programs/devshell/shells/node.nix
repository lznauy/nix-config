# Node.js 开发环境
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
  ];

  env = {
    NPM_CONFIG_PREFIX = "$HOME/.npm";
  };

  shellHook = ''
    echo "📦 Node.js $(node --version) 已加载"
  '';
}
