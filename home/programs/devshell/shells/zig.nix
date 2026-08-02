# Zig 开发环境
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    zls
  ];

  shellHook = ''
    echo "Zig $(zig version) 已加载"
  '';
}
