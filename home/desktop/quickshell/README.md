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

### 配置入口

`default.nix` 组合 `todo/`、`dynamic-island/`，并部署共享的 `shared/Palette.js`。每个组件的 `default.nix` 维护文件清单和启动方式。

- Todo：`shell.qml` 负责界面，`TodoModel.js`、`TodoStore.qml` 负责数据逻辑与存储，`Theme.qml`、`ScreenModel.js` 负责主题和屏幕选择。
- Dynamic Island：`shell.qml` 为入口，`Common/` 放公共组件，`Content/` 放内容组件，`scripts/` 放歌词抓取脚本。

### 添加与修改组件

1. 每个组件使用独立目录，启动命令统一命名为 `qs-<name>`。
2. 新增源码文件时，在该组件的 `files` 列表中声明相对文件名；部署目标由文件名生成。Todo 的服务重启触发清单同时从这里生成，共享配色文件作为额外依赖保留。
3. 部署默认允许覆盖目标位置已有文件；已有不强制覆盖的文件保留在 `force` 的例外清单中。新增文件时应确认所需覆盖策略。
4. 通用配色维护在 `shared/Palette.js`；组件自己的主题和布局继续留在组件目录。
5. 新组件在 `home/desktop/quickshell/default.nix` 的 `imports` 中注册。

### 启动方式

Todo 由 `quickshell-todo.service` 跟随图形会话启动，`qs-todo` 通过 IPC 切换面板；服务未运行时，启动器会先启动服务再显示面板。

Dynamic Island 使用 XDG autostart 启动，也提供 `qs-island` 命令和应用菜单入口。启动方式在各自组件的配置中维护。
