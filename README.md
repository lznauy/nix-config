<div align="center">

# lznauy's NixOS Flake

**我的 NixOS 个人配置，持续完善中。**

![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?style=flat&logo=nixos&logoColor=white)
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

### 双机配置

flake 输出两套 `nixosConfigurations`：

| 主机 | 用途 |
|------|------|
| `nixos` | 主机 — VMware 桌面机，完整桌面 + HM |
| `vm-k3s` | K3s 集群虚拟机，精简配置 |

两者共享 `hosts/base.nix` 公共基础。

</td>
<td width="50%">

### 目录结构

```
hosts/           → 系统层配置
  common/          共享基础（base、i18n、secrets、clash）
  physical/        物理机
  vmware/          VMware 桌面机
  virtual/         K3s 虚拟机
home/            → 用户层配置
  base/            密钥、输入法
  desktop/         窗口、面板、终端
  shell/           Fish、Zsh
  programs/        应用、devshell、Nixvim、AI
  stylix/          主题
  xdg/             MIME、自启动
pkgs/            → 自定义包
secrets/         → sops-nix 密钥
```

### 系统维护

- **generation 限制**：`boot.loader.systemd-boot.configurationLimit = 30`，每次 rebuild 自动清理，保留最近 30 个回滚点
- **自动 GC**：每周执行 `nix-collect-garbage --delete-older-than 7d`，释放无用的 store 路径

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
├── default.nix        # 入口，汇总 packages 和 imports
├── base/              # 密钥管理、fcitx5 输入法
├── desktop/           niri · noctalia · hyprlock · kitty · fuzzel
├── shell/             fish · zsh
├── programs/
│   ├── ai/            Claude Code / OpenCode + skills 复用
│   ├── devshell/      模块化开发环境
│   ├── nixvim/        Neovim 配置
│   └── apps.nix       日常应用
├── xdg/               MIME 类型、自启动、桌面文件
└── stylix/            主题配置
```

</details>

<details>
<summary><b>模块化开发环境</b></summary>

<br/>

`devshell/` 按语言拆分，通过 `inputsFrom` 组合：

| 模块 | 内容 |
|------|------|
| `base.nix` | 通用工具链 |
| `python.nix` | Python 工具 |
| `node.nix` | Node.js 工具 |
| `go.nix` | Go 工具 |

组合矩阵：`default` = 全部 · `python` / `node` / `go` = 单语言 + base

</details>

<details>
<summary><b>AI Skills 系统</b></summary>

<br/>

`programs/ai/` 通过统一的 skills / rules / context 接口同时配置 Claude Code 和 OpenCode，技能定义在 `skills/` 子目录下复用。

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
