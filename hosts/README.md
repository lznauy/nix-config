# Hosts

## 结构

```
hosts/
├── common/       # 共享模块（所有 host 共用）
├── vmware/       # VMware 虚拟机
├── physical/     # 物理机
└── virtual/      # k3s VM
```

桌面主机由 `default.nix`（机器差异）和 `hardware.nix`（硬件）组成，共同引用 `profiles/desktop.nix`。K3s VM 由 `virtual/default.nix` 定义输出，组合 `k3s.nix` 与 `base.nix`，不使用独立的 `hardware.nix`。`common/` 中的模块由各主机按需引用。

## 部署命令

```bash
# 重建当前系统（应用配置变更）
nh os switch /path/to/flake

# 测试配置：立即激活，但不设为启动默认
nh os test /path/to/flake

# 仅构建、不激活（检查是否能通过）
nh os build /path/to/flake
```

## 切换 Host

```bash
# VMware 虚拟机
nh os switch /path/to/flake#nixos

# 物理机
nh os switch /path/to/flake#physical

# k3s VM（构建并启动 VM）
nh os build-vm /path/to/flake#vm-k3s
```

`#nixos`、`#physical` 是 flake 中的配置名称；`-H` 用于部署到远程主机时指定目标主机名。

## 安装新系统

在 NixOS Live ISO 中执行：

```bash
# 1. 分区、格式化、挂载到 /mnt
# 2. 生成硬件配置（可选）
nixos-generate-config --root /mnt

# 3. 从 flake 安装（会使用对应 host 的配置）
nh os install /path/to/flake#physical /mnt

# 4. 重启进入新系统
reboot
```

## 更新依赖

```bash
# 更新所有 inputs（会同时更新系统基座和定制包的依赖，可能触发源码重编译）
nix flake update --flake /path/to/flake

# 只更新 witr、tailcat、VS Code 和 mark-shot 运行依赖使用的 unstable 源
nix flake update nixpkgs-unstable --flake /path/to/flake

# 只更新 AI 工具，保持系统基座及 niri 的依赖不变
nix flake update llm-agents --flake /path/to/flake
```

日常只修改配置时，直接 `nh os switch`，无需先更新 lock 文件。按需更新单个 input，
可以减少定制包因依赖变化而重新编译的次数。

## 二进制缓存与构建耗时

缓存必须匹配完整构建定义。niri、pipx、witr、tailcat 使用 nixpkgs 原版；Claude Code
直接使用 llm-agents 的 package，以便复用各自缓存。Clash 使用独立固定的 nixpkgs
快照，quien、mark-shot 和 SPlayer Next 下载官方固定版本二进制后重打包。

`nixpkgs-cached` 固定到具体快照，全量 update 不会自动推进它。
升级时先修改 flake.nix 中对应 URL，再更新 lock 并核对 dry-run；不能只凭软件版本号
相同判断缓存可用。已有本地产物会直接复用，不会因修改桌面配置而重编译软件。

构建前可查看计划（替换为实际 host）：

```bash
nix build /path/to/flake#nixosConfigurations.physical.config.system.build.toplevel --dry-run
```

`will be fetched` 是下载缓存；`will be built` 也包括生成配置、服务、链接目录等
轻量步骤，数量多不代表大量软件在源码编译。应查看其中是否真的列出了
`niri-*.drv` 等软件包。

可在可信构建机上将定制产物上传到自建二进制缓存，让其他机器直接下载；单纯增加
公共镜像无法提供这些定制产物。不要为了命中缓存直接删除仍需使用的功能补丁或
测试修复。

当前桌面软件的逐项核查结果见 [缓存核查记录](cache-audit.md)。

SPlayer Next 的版本、数据保留及验证方式见 [迁移记录](splayer-migration.md)。

## 实用技巧

```bash
# 查看当前系统使用的 flake 来源
nixos-version --json

# 查看有哪些可用的 nixosConfiguration
nix flake show /path/to/flake

# 列出所有世代
nh os list-generations

# 切换到上一代（回滚）
nh os switch /path/to/flake -- --rollback
```
