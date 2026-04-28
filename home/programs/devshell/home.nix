# home-manager 入口：从 package.nix 提取包全局安装
{ pkgs, ... }:
let
  result = import ./package.nix { inherit pkgs; };
in
{
  home.packages = result.packages;
}
