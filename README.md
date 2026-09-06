<div align="center">

# lznauy's NixOS Flake

**我的 NixOS 个人配置，持续完善中。**

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=flat&logo=nixos&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-Niri-8800aa?style=flat&logo=wayland&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-Nixvim-57A143?style=flat&logo=neovim&logoColor=white)
![Fish](https://img.shields.io/badge/Shell-Fish-4C9900?style=flat&logo=gnubash&logoColor=white)
![Claude](https://img.shields.io/badge/AI-Claude_Code-D97757?style=flat&logo=anthropic&logoColor=white)

<br/>

<img src="./img/desktop.png" width="100%" alt="desktop screenshot"/>

</div>

## Architecture

<table>
<tr>
<td width="50%">

### 主机配置

flake 输出三套 `nixosConfigurations`：

| 主机 | 用途 |
|------|------|
| `nixos` | 主机 — VMware 桌面机，完整桌面 + HM |
| `physical` | 物理桌面机，完整桌面 + HM |
| `vm-k3s` | K3s 集群虚拟机，精简配置 |

桌面主机共享 `profiles/desktop.nix`，K3s VM 使用独立的精简系统配置。

</td>
<td width="50%">

### 目录结构

```
config/           → 用户与共享 provider 数据
profiles/         → 可复用的主机配置组合
hosts/           → 系统层配置
  common/          共享基础（base、i18n、secrets、clash）
  physical/        物理机
  vmware/          VMware 桌面机
  virtual/         K3s 虚拟机
home/            → 用户层配置
  base/            输入法
  desktop/         窗口、面板、终端
  shell/           Fish、Zsh
  programs/        应用、devshell、Nixvim、AI
  stylix/          主题
  xdg/             MIME、桌面文件
pkgs/             → 自定义包
overlays/         → nixpkgs 包覆盖
secrets/          → sops-nix 密钥
```

### 配置修改入口

- 用户信息：`config/user.nix`；AI provider 与模型：`config/ai.nix`。
- 桌面组合入口：`profiles/desktop.nix`，统一组织外部模块、overlays、Home Manager 和系统桌面策略；硬件与机器差异：`hosts/<主机>/`。
- 用户应用：`home/programs/`；桌面组件：`home/desktop/`，自启动配置随所属组件维护。
- 开发工具清单：`home/programs/devshell/shells/`，同时供 Home Manager 和 devShell 使用。
- 自定义包：`pkgs/`；包覆盖与临时上游修复：`overlays/default.nix`。

### 检查与格式化

在仓库根目录运行，工具版本使用 `flake.lock` 中的 nixpkgs：

| 命令 | 用途 |
|------|------|
| `just check` | 求值所有主机和 flake 输出，运行 Nix 格式、Statix、Deadnix 检查及现有 JS/Python 测试 |
| `just test` | 仅运行现有 JS/Python 测试 |
| `just eval` | 仅求值三套主机的完整系统派生 |
| `just fmt` | 格式化 Nix 文件 |

`just check` 等价于 `nix flake check path:.`，不构建或激活完整系统。检查派生会构建，首次运行可能需要下载工具。使用 `path:.` 是为了让新建但尚未被 Git 跟踪的配置也参与检查；新增文件仍需在提交时加入 Git。

公共 Nix 构建预算在 `hosts/common/base.nix` 中使用默认值；机器需要不同预算时，直接在主机配置中设置 `nix.settings.max-jobs` 和 `nix.settings.cores`。

### 系统维护

- `nh os test` 用于测试当前配置，`nh os boot` 设为下次启动配置，`nh os switch` 立即激活并设为默认。

</td>
</tr>
</table>

## Modules

<details>
<summary><b>Home Manager 集成</b></summary>

<br/>

Home Manager 作为 NixOS 模块集成（非独立 flake），用户配置统一在 `home/` 下：

```
home/
├── default.nix        # 入口，组合用户模块
├── base/              # fcitx5 输入法
├── desktop/           niri · noctalia · hyprlock · kitty · fuzzel
├── shell/             fish · zsh
├── programs/
│   ├── ai/            Claude Code / OpenCode + skills 复用
│   ├── devshell/      模块化开发环境
│   ├── nixvim/        Neovim 配置
│   └── apps.nix       日常应用
├── xdg/               MIME 类型、桌面文件
└── stylix/            主题配置
```

</details>

<details>
<summary><b>模块化开发环境</b></summary>

<br/>

`devshell/` 按语言拆分，通过共享工具清单组合：

| 模块 | 内容 |
|------|------|
| `base.nix` | 通用工具链 |
| `python.nix` | Python 工具 |
| `node.nix` | Node.js 工具 |
| `go.nix` | Go 工具 |
| `rust.nix` | Rust 工具 |
| `zig.nix` | Zig 工具 |

组合矩阵：`default` = 全部 · `python` / `node` / `go` / `rust` / `zig` = 单语言 + base

</details>

<details>
<summary><b>AI Skills 系统</b></summary>

<br/>

`config/ai.nix` 集中 provider 和模型名称，`programs/ai/` 负责转换成各客户端自己的配置格式。

</details>

<details>
<summary><b>主题方案</b></summary>

<br/>

Stylix 采用 `autoEnable = false` 策略，仅对显式声明的目标生效（kitty、nixvim、fuzzel），避免干扰手动配置的组件（noctalia、hyprlock、starship）。配色支持自定义 YAML 和内置 base16 方案切换。

当前方案：**midnight**（自定义暗色配色）

</details>

<details>
<summary><b>密钥管理</b></summary>

<br/>

使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理敏感配置，密钥定义在 `secrets/secrets.yaml`，通过 `hosts/common/secrets/` 下的模板文件渲染到各工具配置。

</details>

---

<div align="center">

**Tech Stack**

`NixOS` · `Niri` · `Noctalia Shell` · `Fish` · `Nixvim` · `Stylix` · `Claude Code` · `OpenCode` · `sops-nix` · `Docker` · `K3s`

</div>
