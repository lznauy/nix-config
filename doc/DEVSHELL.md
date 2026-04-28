# DevShell 开发环境配置

## 概述

本项目使用模块化方式管理开发环境，一套定义同时服务两个场景：

1. **`nix develop`**：临时隔离的交互式开发环境
2. **home-manager**：永久全局安装的工具

配置目录：`home/programs/devshell/`

## 目录结构

```
home/programs/devshell/
├── default.nix    # nix develop 入口：定义 shell 组合，用 inputsFrom 合并
├── package.nix    # 提取各模块 buildInputs，供 home-manager 使用
├── home.nix       # home-manager 入口：调用 package.nix 注入包
└── shells/        # 语言模块目录
    ├── base.nix   # 基础编译工具（gcc、gnumake）
    ├── python.nix # Python 环境
    ├── node.nix   # Node.js 环境
    └── go.nix     # Go 环境
```

## 使用方式

### nix develop（临时环境）

```bash
nix develop .#default     # 全部环境（base + python + node + go）
nix develop .#python      # Python + 基础编译工具
nix develop .#go          # Go + 基础编译工具
nix develop .#node        # Node.js + 基础编译工具
exit                      # 退出，环境消失
```

### home-manager（全局安装）

通过 `home.nix` → `package.nix` 自动提取所有模块的包，永久安装到系统。

## 核心机制

### inputsFrom

`default.nix` 使用 `inputsFrom` 组合多个 `mkShell`，自动合并所有 `buildInputs`、`env`、`shellHook`：

```nix
shells = {
  default = [ base python node go ];  # 组合所有模块
  python = [ base python ];           # 只组合需要的
};

buildShell = modules:
  pkgs.mkShell {
    inputsFrom = modules;  # 自动继承所有模块的内容
  };
```

### shellHook

进入 `nix develop` 时自动执行的脚本，用于打印提示或设置临时变量：

```nix
shellHook = ''
  echo "🐍 Python $(python3 --version) 已加载"
'';
```

### env

静态环境变量，会被 `inputsFrom` 继承，也可被 `package.nix` 提取到系统：

```nix
env = {
  GOPATH = "$HOME/go";
};
```

## 新增语言规范

### 步骤一：创建语言文件

在 `home/programs/devshell/shells/` 下新建 `<语言>.nix`：

```nix
# Rust 开发环境
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
  ];

  env = {
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  shellHook = ''
    echo "🦀 Rust $(rustc --version | cut -d' ' -f2) 已加载"
  '';
}
```

### 步骤二：注册到 default.nix

在 `default.nix` 中导入模块并添加到组合：

```nix
let
  # 加载模块
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };
  rust = import ./shells/rust.nix { inherit pkgs; };  # ← 新增

  # 定义组合
  shells = {
    default = [ base python node go rust ];  # ← 加入 default
    python = [ base python ];
    go = [ base go ];
    node = [ base node ];
    rust = [ base rust ];                    # ← 新增单独组合
  };
```

### 步骤三：注册到 package.nix

在 `package.nix` 中导入模块，使其包被 home-manager 全局安装：

```nix
let
  base = import ./shells/base.nix { inherit pkgs; };
  python = import ./shells/python.nix { inherit pkgs; };
  node = import ./shells/node.nix { inherit pkgs; };
  go = import ./shells/go.nix { inherit pkgs; };
  rust = import ./shells/rust.nix { inherit pkgs; };  # ← 新增

  modules = [ base python node go rust ];       # ← 加入列表
```

### 文件模板

```nix
# <语言名>.nix
{ pkgs }:
pkgs.mkShell {
  # 必填：包列表
  buildInputs = with pkgs; [
    # 编译器/运行时
    # LSP 服务器
    # 格式化工具
    # 包管理器
  ];

  # 可选：静态环境变量
  env = {
    # KEY = "value";
  };

  # 可选：进入 shell 时执行的脚本
  shellHook = ''
    echo "提示信息"
  '';
}
```

## 注意事项

- `shellHook` 只在 `nix develop` 时生效，home-manager 安装时会忽略
- `env` 在两个场景都生效
- `buildInputs` 是包的主要载体，`inputsFrom` 和 `package.nix` 都依赖它
- 每个语言文件只负责自己的环境，组合逻辑在 `default.nix` 中管理
