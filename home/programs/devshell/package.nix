# 提取各模块的包，用于 home-manager 全局安装
{ pkgs }:
let
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };

  modules = [ base python node go ];
in
{
  # 提取所有 buildInputs
  packages = builtins.concatLists (map (m: m.buildInputs or []) modules);
}
