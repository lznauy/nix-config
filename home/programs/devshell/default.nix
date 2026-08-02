# nix develop 开发环境定义
# 用 inputsFrom 组合模块
{ pkgs }:
let
  # 加载各语言模块
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };
  rust = import ./shells/rust.nix { inherit pkgs; };
  zig = import ./shells/zig.nix { inherit pkgs; };

  # 定义 shell 组合
  shells = {
    default = [ base python node go rust zig ];
    python = [ base python ];
    node = [ base node ];
    go = [ base go ];
    rust = [ base rust ];
    zig = [ base zig ];
  };

  # 构建 shell：用 inputsFrom 合并模块
  buildShell = modules:
    pkgs.mkShell {
      inputsFrom = modules;
    };
in
# 返回所有组合好的 shell
builtins.mapAttrs (_name: buildShell) shells
