# home-manager 入口：提取所有语言模块的包，全局安装
{ pkgs, ... }:
let
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };
  rust = import ./shells/rust.nix { inherit pkgs; };
  zig = import ./shells/zig.nix { inherit pkgs; };

  modules = [ base python node go rust zig ];
in
{
  home.packages = builtins.concatLists (map (m: m.buildInputs or []) modules);
}
