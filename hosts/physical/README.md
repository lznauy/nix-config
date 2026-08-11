## Windows 11 Pro 办公虚拟机

物理机配置包含 KVM/libvirt、virt-manager、软件 TPM 2.0 和一个 Win11 创建命令。默认规格为 4 vCPU、6 GiB 内存和 64 GiB 稀疏 qcow2 磁盘，并使用预置 Microsoft 默认密钥的 OVMF Secure Boot 固件；虚拟机不会随宿主机自动启动。

### 1. 应用配置

```bash
nh os switch /path/to/flake#physical -H nixos
```

切换后注销并重新登录一次，让 `lznauy` 的 `kvm`、`libvirtd` 组权限生效。

### 2. 下载官方 ISO

从 [微软 Windows 11 下载页](https://www.microsoft.com/software-download/windows11) 获取 x64 多版本 ISO。安装期间选择 **Windows 11 Pro**；没有许可证时选择“我没有产品密钥”，不要使用第三方修改镜像或激活脚本。

### 3. 创建并安装

```bash
win11-vm-create ~/Downloads/Win11.iso
```

第一次运行会把 nixpkgs 提供的 VirtIO 驱动 ISO 导入 libvirt 的 `default` 存储池；以后创建时直接复用该卷，不会枚举整个 `/nix/store`。

安装器如果没有显示 64 GiB 磁盘，点击“加载驱动程序”，在第二张光盘中选择：

```text
viostor/w11/amd64
```

如果安装阶段没有网络，在同一张驱动光盘中选择：

```text
NetKVM/w11/amd64
```

Windows 首次安装结束并重启前后，在宿主机执行：

```bash
win11-vm-finish-install
```

该命令会弹出 Windows 安装 ISO、切换为硬盘启动并重启 VM，同时保留 VirtIO 驱动光盘；命令可以安全地重复执行。进入桌面后，从 VirtIO 光盘运行 `virtio-win-guest-tools.exe`，安装磁盘、网络、气球设备和 QEMU Guest Agent 驱动。随后运行 Windows Update，再通过 virt-manager 创建名为 `clean-install` 的快照。

### 日常使用

从应用菜单启动 **Virtual Machine Manager**，连接 `QEMU/KVM - system` 后即可启动或关闭 `win11-pro`。Windows ISO 在安装完成后可以通过虚拟机硬件详情弹出并删除；VirtIO 驱动光盘可以保留。

### 卸载虚拟机

先在 virt-manager 中确认不再需要虚拟机数据，然后删除 `win11-pro`，并勾选删除关联的 `win11-pro.qcow2` 存储卷。此操作不可恢复，但不会影响宿主机文件。
