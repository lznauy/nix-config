# 基础编译工具
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    gnumake
    binutils
    cmake
    pkg-config
    alsa-lib
    sqlite-interactive
  ];
}
