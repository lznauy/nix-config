# XDG Dotfile 管理

核心原则：家目录 `~/` 下不应出现应用生成的 dotfile，仅保留 XDG 标准目录。

## XDG 标准目录

| 变量 | 路径 | 用途 |
|------|------|------|
| `XDG_CONFIG_HOME` | `~/.config` | 配置 |
| `XDG_DATA_HOME` | `~/.local/share` | 应用数据 |
| `XDG_CACHE_HOME` | `~/.cache` | 缓存（可删） |
| `XDG_STATE_HOME` | `~/.local/state` | 状态/历史 |

## 新增软件步骤

1. **查 XDG 支持** — [Arch Wiki 列表](https://wiki.archlinux.org/title/XDG_Base_Directory#Supported)
   - 原生支持 → 通常无需配置
   - 环境变量支持 → 在 `home/xdg/default.nix` 的 `home.sessionVariables` 添加
   - 不支持 → 记入下方白名单
2. **优先用 HM 模块** — `programs.<name>` / `services.<name>` 通常内置 XDG 支持
3. **选对原语**：
   - 配置 → `xdg.configFile`
   - 数据 → `xdg.dataFile`
   - 敏感配置 → sops-nix templates 直接渲染
   - **不要用** `home.file.".config/..."`
4. **环境变量引用 `config.xdg.*`**，不要硬编码路径

## 已配置的环境变量

参见 `home/xdg/default.nix`：`GOPATH`, `CARGO_HOME`, `NPM_CONFIG_*`, `WGETRC`, `LESSHISTFILE`, `GNUPGHOME`, `PYTHON_HISTORY`, `CLAUDE_CONFIG_DIR`

## 不可迁移白名单

| 文件 | 原因 |
|------|------|
| `.bash_profile` / `.bashrc` / `.profile` | Bash 启动硬编码 |
| `.ssh/` | OpenSSH 硬编码 |
| `.pki/` | NSS/Chromium 硬编码 |
| `.nix-defexpr/` | Nix 遗留 |
| `.gtkrc-2.0` | GTK2 硬编码 |

新增不可迁移 dotfile 时须在此登记。

## 项目文件结构

```
home/
├── default.nix              # 入口，imports 所有子模块
├── base/
│   └── fcitx5.nix           # 输入法
├── desktop/
│   ├── niri/                # 窗口管理器
│   ├── noctalia/            # 主题/壁纸
│   ├── hyprlock/            # 锁屏
│   ├── fuzzel.nix           # 应用启动器
│   ├── kitty.nix            # 终端
│   └── gtk.nix              # GTK 主题
├── shell/
│   ├── default.nix
│   ├── fish/                # fish + starship
│   └── zsh/                 # zsh
├── xdg/
│   ├── default.nix          # xdg.enable + sessionVariables + bash
│   ├── mime.nix             # 默认应用关联
│   ├── autostart.nix        # 自启动
│   └── desktop-files.nix    # desktop 文件
└── programs/
    ├── ai.nix               # AI 工具
    ├── apps.nix             # 桌面应用
    ├── devtools.nix          # 开发工具
    ├── git.nix              # programs.git
    ├── nixvim.nix           # programs.nixvim
    ├── kitty.nix            # programs.kitty
    └── ...                  # 其他 programs.*
```

**规则**：
- 有 HM 模块 → 独立 `programs/<name>.nix`
- 无 HM 模块 → `home.packages` 安装，环境变量在 `xdg/default.nix` 管理
- 敏感配置 → `base/secrets.nix` 用 `xdg.configFile` + `mkOutOfStoreSymlink`
