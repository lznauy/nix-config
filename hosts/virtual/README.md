# hosts/virtual — QEMU/KVM 虚拟机

## 目录结构

```
hosts/virtual/
├── default.nix # VM 注册表（flake.nix 通过 import 引入）
├── base.nix    # 所有 VM 共享的基础配置
├── k3s.nix     # k3s 单节点学习集群
└── README.md
```

## 架构：三层继承

```
hosts/common/base.nix         ← 全局基础（nix 设置、openssh、基础工具）
hosts/common/locale.nix       ← 时区与 locale
  └─ hosts/virtual/base.nix   ← VM 基础（qemu-guest、串口控制台、DHCP、网络工具）
      └─ hosts/virtual/k3s.nix ← VM 实例（k3s 服务、用户、端口转发、资源配额）
```

每新增一个 VM，只需 import 上面两层，再写自己的业务配置。

## 新建 VM 规范

### 1. 创建配置文件

在 `hosts/virtual/` 下新建 `<name>.nix`，模板如下：

```nix
# <用途说明>
{ pkgs, lib, ... }:
{
  imports = [
    ../base.nix   # 全局基础
    ./base.nix    # VM 基础
  ];

  networking.hostName = "<name>";

  # 用户配置
  users.users.root.initialPassword = "admin@123";
  users.users.lznauy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "admin@123";
  };

  # 磁盘和引导（build-vm 会自动覆盖为虚拟磁盘）
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  boot.loader.grub.devices = [ "/dev/vda" ];
  boot.loader.timeout = 0;

  # VM 资源配置
  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;   # 内存 (MB)
    cores = 2;           # CPU 核心数
    diskSize = 10240;    # 磁盘 (MB)
    forwardPorts = [
      { from = "host"; host.port = 2222; guest.port = 22; }  # SSH
    ];
  };
}
```

### 2. 注册到 default.nix

在 `hosts/virtual/default.nix` 中添加：

```nix
vm-<name> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ ./<name>.nix ];
};
```

`default.nix` 会被 `flake.nix` 通过 `//` 合并到 `nixosConfigurations`，无需改动 `flake.nix`。

**命名规则**：flake 属性名统一用 `vm-` 前缀，如 `vm-k3s`、`vm-web`。

## 使用方法

### 构建 VM

```bash
nh os build-vm .#vm-<name>
```

### 构建并立即运行

```bash
nh os build-vm .#vm-<name> -r
```

### 手动运行已构建的 VM

```bash
./result/bin/run-<name>-vm
```

### 指定磁盘路径

默认磁盘镜像创建在当前目录下（如 `./k3s.qcow2`）。通过 `NIX_DISK_IMAGE` 环境变量可指定自定义路径：

```bash
# 使用已有的磁盘镜像（首次运行不存在时会自动创建）
NIX_DISK_IMAGE=/data/vms/k3s.qcow2 ./result/bin/run-k3s-vm
```

### `-nographic` 纯终端模式

`-nographic` 的作用：
1. **关闭图形窗口** — 不弹出 QEMU 窗口
2. **串口重定向到终端** — VM 的串口输出直接显示在当前终端，可交互登录

这依赖 `base.nix` 中的串口配置（`console=ttyS0,115200`），两者配合才能在终端里操作 VM。

```bash
# 纯终端运行，Ctrl+A X 退出
./result/bin/run-k3s-vm -nographic
```

适合 SSH 不可用时（如网络未通、忘记密码）直接在终端操作 VM。日常使用建议用 SSH 替代。

### SSH 连接（映射了端口的 VM）

```bash
ssh -p 2222 lznauy@localhost
```

## 现有 VM

| 名称 | 用途 | 资源 | 端口映射 |
|------|------|------|----------|
| `vm-k3s` | k3s 学习集群 | 4GB RAM / 2 核 / 20GB 磁盘 | 6443→k8s API, 8080→HTTP, 2222→SSH |
