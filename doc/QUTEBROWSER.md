# Qutebrowser 使用说明

配置入口：`home/programs/qutebrowser/default.nix`

## 基本操作

### Vim 风格导航

| 按键 | 功能 |
|------|------|
| `h/j/k/l` | 左/下/上/右滚动 |
| `gg` | 滚动到顶部 |
| `G` | 滚动到底部 |
| `d` | 关闭标签页 |
| `u` | 撤销关闭标签页 |
| `r` | 刷新页面 |
| `R` | 强制刷新（跳过缓存） |
| `o` | 打开 URL（当前标签） |
| `O` | 打开 URL（新标签） |
| `go` | 编辑当前 URL |
| `H` | 后退 |
| `L` | 前进 |
| `/` | 搜索 |
| `n` | 下一个搜索结果 |
| `N` | 上一个搜索结果 |
| `:` | 进入命令模式 |
| `i` | 进入插入模式（网页表单） |
| `Esc` | 退回普通模式 |

### 标签页操作

| 按键 | 功能 |
|------|------|
| `J` / `K` | 切换到左/右标签页 |
| `gp` | 标签页左移 |
| `gn` | 标签页右移 |
| `gw` | 关闭标签页 |
| `<Ctrl-w>` | 关闭标签页 |
| `<Ctrl-n>` | 新窗口打开 |
| `<Ctrl-1>` ~ `<Ctrl-0>` | 跳转到第 1~10 个标签页 |
| ` 1` ~ ` 0` | 同上（空格+数字） |

### 快捷书签

| 按键 | 网站 |
|------|------|
| `gh` | 打开主页（DuckDuckGo） |
| 无 | `clash` - Metacubex 面板 |
| 无 | `mynixos` - MyNixOS |
| 无 | `github` - GitHub |
| 无 | `openwrt` - 路由器管理 |
| 无 | `chatgpt` - ChatGPT |
| 无 | `nixvim` - Nixvim 文档 |
| 无 | `hyprland` - Hyprland Wiki |
| 无 | `nerdfont` - Nerd Font 备忘录 |
| 无 | `youtube` - YouTube |

使用方式：`go` 打开快速跳转列表，选择书签名称即可打开对应网站。

## 搜索引擎

| 前缀 | 搜索引擎 |
|------|---------|
| 无前缀 | DuckDuckGo（默认） |
| `nix` | MyNixOS |

使用方式：`o` 进入 URL 栏，输入 `nix nixos home-manager` 搜索。

## 主题

- 主题由 Stylix 自动管理（base16 配色方案）
- 配置文件：`home/programs/qutebrowser/theme.nix`
- DuckDuckGo 配色：`home/programs/qutebrowser/duckduckgo-colorscheme.nix`

**启用 DDG 主题色：**
1. 构建后打开 qutebrowser
2. 访问 DuckDuckGo 设置页
3. F12 打开控制台
4. 粘贴 `~/.config/qutebrowser/greasemonkey/duckduckgo-colorscheme.js` 内容执行

## 字体与显示

| 设置 | 值 |
|------|-----|
| UI 字体 | Noto Sans CJK SC, 14pt |
| 网页字号 | 18px |
| 缩放 | 100% |
| 深色模式 | 开启（网页偏好） |
| 中文优先 | accept_language: zh-CN,zh,en |

## 界面配置

| 设置 | 值 |
|------|-----|
| 标签页位置 | 顶部 |
| 标签页宽度 | 30% |
| 状态栏 | 按模式显示 |
| 完成框高度 | 30% |
| 滚动条 | 隐藏 |
| 平滑滚动 | 开启 |
| 提示圆角 | 1px |

## 常用命令

在命令模式（`:`）下：

```
:open <url>          # 打开网址
:tab-close           # 关闭标签页
:tab-only            # 关闭其他标签页
:back                # 后退
:forward             # 前进
:reload              # 刷新
:stop                # 停止加载
:zoom <level>        # 设置缩放（如 :zoom 150）
:clear-cookies       # 清除 cookies
:devtools            # 打开开发者工具
:print               # 打印页面
:bookmark-add        # 添加书签
:quit                # 退出
:wq                  # 保存并退出
```

## 自定义配置

配置修改后需要 `nh os switch` 重新构建：

- **添加快捷书签**：在 `quickmarks` 中添加
- **修改搜索引擎**：在 `searchEngines` 中添加
- **调整字体**：修改 `fonts` 设置
- **修改快捷键**：在 `keyBindings` 中添加
- **主题颜色**：修改 `home/stylix/colorschemes/` 下的配色文件
