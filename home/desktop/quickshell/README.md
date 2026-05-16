# Quickshell 自定义组件

基于 [quickshell](https://github.com/quickshell/quickshell) 的 Wayland 弹出组件集，通过 Nix home-manager 管理。

## 使用

`nixos-rebuild switch` 后，终端直接敲对应命令：

```
qs-todo     # 打开待办/便签
qs-island   # 启动 Dynamic Island（歌词/时钟悬浮条）
```

绑定快捷键（niri 示例）：

```kdl
binds {
    Mod+Shift+T { spawn "qs-todo"; }
    Mod+Shift+I { spawn "qs-island"; }
}
```

## 已有组件

| 组件 | 命令 | 功能 | 外部依赖 |
|------|------|------|----------|
| dynamic-island | `qs-island` | 屏幕底部悬浮药丸，播放音乐时自动展开显示滚动歌词，折叠时 hover 显示时钟；支持 MPRIS 播放器管理和多屏独立实例 | Python 3（歌词抓取） |
| todo | `qs-todo` | 待办列表 + 便签，数据存 `~/.local/share/quickshell/notes.json` | 无 |

## 添加新组件规范

### 目录结构

```
home/desktop/quickshell/
├── README.md          # 本文件
├── todo/
│   ├── default.nix
│   ├── shell.qml
│   ├── Theme.js
│   └── ScreenModel.js
└── dynamic-island/
    ├── default.nix
    ├── shell.qml
    ├── Common/        # 共享模块（Appearance, Animations, Motion 等）
    ├── Content/       # 内容组件（ClockContent, LyricsContent）
    └── scripts/       # 外部脚本（lyrics_fetcher.py）
```

### default.nix 规范

```nix
{ config, pkgs, ... }:
{
  # 1. 源码文件链接到 ~/.config/quickshell/<component>/
  xdg.configFile = {
    "quickshell/<component>/main.qml" = { source = ./main.qml; force = true; };
    # ... 其他文件，同样加 force = true
  };

  # 2. 启动器脚本 qs-<component>
  home.packages = [
    (pkgs.writeShellScriptBin "qs-<component>" ''
      exec ${pkgs.quickshell}/bin/quickshell \
        -p ${config.xdg.configHome}/quickshell/<component>/main.qml
    '')
  ];
}
```

### 规则

1. **每个组件一个独立目录**，QML/JS 文件不跨组件共享。Theme.js、ScreenModel.js 等各自复制一份，方便独立定制。
2. **入口 QML 文件**使用 `import "./Theme.js" as Theme` 的相对路径，和文件放在同一目录即可。
3. **`xdg.configFile` 加 `force = true`**，确保 nix 重建时覆盖手动修改。
4. **命名约定**：目录名 = 组件名，启动命令 = `qs-<name>`，`home.packages` 里的 script name 保持一致。
5. 完成后在 `home/default.nix` 的 `imports` 列表加一行 `./desktop/quickshell/<component>`。
