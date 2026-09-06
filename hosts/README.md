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
# 更新所有 inputs（会同时更新 nixpkgs 和 nixpkgs-unstable）
nix flake update /path/to/flake

# 只更新 Clash 使用的 unstable 源
nix flake update nixpkgs-unstable --flake /path/to/flake
```

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
