# Stylix 配置说明

## 概述

Stylix 是 NixOS/home-manager 的统一主题管理模块。本项目使用 `autoEnable = false` 模式，只对明确启用的目标应用生效。

配置入口：`home/stylix/default.nix`

## 当前配色方案

- **方案名称**：在 `home/stylix/default.nix` 的 `colorScheme.name` 中配置
- **可选方案**：catppuccin-mocha/frappe/latte/macchiato、nord、tokyo-night-moon、solarized-dark、rose-pine-moon、darcula、gruvbox-dark-medium、monokai、moonlight、kanagawa
- **切换方式**：修改 `name` 字段，所有接入 stylix 的应用自动跟随变色
- **自定义方案**：在 `home/stylix/colorschemes/` 目录添加 yaml 文件，设置 `custom = true`

## 当前接入的应用

### 方式一：内置 Target（自动配色）

Stylix 内置了对这些应用的配色支持，只需 `enable = true`：

| 应用 | Target 配置 | 说明 |
|------|------------|------|
| kitty | `stylix.targets.kitty.enable = true` | 终端配色 + 字体 |
| nixvim | `stylix.targets.nixvim.enable = true` | 编辑器 base16 主题 |
| fuzzel | `stylix.targets.fuzzel.enable = true` | 启动器配色 + 字体 |

### 方式二：手动引用颜色（精细控制）

在模块中通过 `config.lib.stylix.colors` 手动引用 base16 颜色：

| 应用 | 文件 |
|------|------|
| qutebrowser | `home/programs/qutebrowser/theme.nix` |
| bottom (btm) | `home/programs/btm.nix` |
| cava | `home/programs/cava.nix` |
| hyprlock | `home/desktop/hyprlock/default.nix` |

### 已禁用 Target 的应用

| 应用 | 原因 |
|------|------|
| noctalia-shell | Target 会覆盖布局设置（opacity 等），与自定义配置冲突 |
| hyprlock | 已手动引用颜色，Target 冗余且冲突 |
| starship | 自定义 toml 使用 catppuccin 风格颜色名（mauve、sky 等），与 base16 调色板不兼容 |

## Base16 颜色系统

Stylix 使用 base16 配色方案，每个方案包含 16 个颜色：

| 颜色代码 | 语义 | 常见用途 |
|---------|------|---------|
| `base00` | 最深背景 | 页面/编辑器背景 |
| `base01` | 次深背景 | 侧边栏/选中行背景 |
| `base02` | 深色表面 | 高亮行/代码块背景 |
| `base03` | 暗色前景 | 注释/行号/占位符 |
| `base04` | 次亮前景 | 副标题/次要文字 |
| `base05` | 主前景 | 正文文字 |
| `base06` | 亮前景 | 标题/强调文字 |
| `base07` | 最亮前景 | 高亮文字 |
| `base08` | 红色 | 错误/删除/变量 |
| `base09` | 橙色 | 数字/布尔值/常量 |
| `base0A` | 黄色 | 警告/类名/类型 |
| `base0B` | 绿色 | 成功/字符串/添加 |
| `base0C` | 青色 | 特殊字符/正则 |
| `base0D` | 蓝色 | 链接/函数/方法 |
| `base0E` | 紫色 | 关键字/标签 |
| `base0F` | 棕色 | 错误标记/废弃代码 |

在 nix 中引用方式：

```nix
{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  # 用法示例
  someSetting = "#${colors.base05}";    # 带 # 前缀
  anotherSetting = "rgb(${colors.base0B})"; # 不带 #，用于 rgba 等格式
}
```

## 接入新应用指南

### 步骤一：确认是否有内置 Target

在 Stylix 源码的 `modules/` 目录下查找对应模块：

- 有 → 使用方式一
- 没有 → 使用方式二

### 步骤二：处理冲突

接入前检查现有配置中是否有与 Target 重叠的选项（字体、颜色、透明度等）。

**有冲突时的处理策略：**

1. **颜色/字体冲突**：移除现有配置，让 Stylix 接管
2. **布局/行为冲突**：禁用 Target，改用手动引用方式
3. **需要保留自定义值**：使用 `lib.mkForce` 强制优先

```nix
# 示例：保留自定义透明度
background_opacity = lib.mkForce "0.8";
```

### 步骤三：验证

构建后检查生成的配置文件：

```bash
nh os switch
# 检查生成的配置
cat ~/.config/<app>/config-file
```

## 注意事项

- `autoEnable = false` 下，必须在 `stylix/default.nix` 的 `targets` 中显式启用 Target
- 手动引用颜色的应用不受 `autoEnable` 影响，随时可用
- Target 可能设置你没注意到的选项（字体、透明度等），接入后务必检查
- 切换配色方案只需改 `name`，无需修改各应用配置
