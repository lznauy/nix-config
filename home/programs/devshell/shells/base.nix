# 基础编译工具
{ pkgs }:
{
  packages = with pkgs; [
    gcc
    gnumake
    binutils
    cmake
    pkg-config
    alsa-lib
    sqlite-interactive
  ];
}
