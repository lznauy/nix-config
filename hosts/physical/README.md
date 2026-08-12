## Windows 11 Pro 办公虚拟机

物理机配置包含 KVM/libvirt、virt-manager、软件 TPM 2.0 和 Win11 管理命令。默认规格为 4 vCPU、5 GiB 内存和 80 GiB 稀疏 qcow2 磁盘，并使用预置 Microsoft 默认密钥的 OVMF Secure Boot 固件。虚拟机不会随宿主机自动启动，宿主机关机时会请求虚拟机正常关机。

宿主机虚拟化配置位于 `virtualisation.nix`，Win11 创建和安装收尾脚本位于 `windows-vm.nix`。各组件的关系如下：

```text
virt-manager / virsh / virt-install
                │
                ▼
             libvirtd
                │
                ▼
             QEMU/KVM
```

virt-manager 是图形管理界面，关闭窗口不会关闭正在运行的虚拟机。libvirtd 管理虚拟机定义、存储池、网络和 QEMU 进程，实际的虚拟化由 QEMU/KVM 完成。这里统一使用系统级连接 `qemu:///system`，虚拟机数据保存在 `/var/lib/libvirt/images`。

### 1. 应用配置

```bash
nh os switch /path/to/flake#physical -H nixos
```

切换后注销并重新登录一次，让 `lznauy` 的 `kvm`、`libvirtd` 组权限生效。

可以用下面的命令确认服务和权限：

```bash
id
systemctl status libvirtd
virsh --connect qemu:///system list --all
```

### 2. 下载官方 ISO

从 [微软 Windows 11 下载页](https://www.microsoft.com/software-download/windows11) 获取 x64 多版本 ISO。安装期间选择 **Windows 11 Pro**；没有许可证时选择“我没有产品密钥”，不要使用第三方修改镜像或激活脚本。

### 3. 创建并安装

```bash
win11-vm-create ~/Downloads/Win11.iso
```

第一次运行会把 nixpkgs 提供的 VirtIO 驱动 ISO 导入 libvirt 的 `default` 存储池；以后创建时直接复用该卷，不会枚举整个 `/nix/store`。

安装器如果没有显示 80 GiB 磁盘，点击“加载驱动程序”，在第二张光盘中选择：

```text
viostor/w11/amd64
```

如果安装阶段没有网络，在同一张驱动光盘中选择：

```text
NetKVM/w11/amd64
```

进入 Windows 桌面后，从 VirtIO 光盘运行 `virtio-win-guest-tools.exe`，安装磁盘、网络、气球设备和 QEMU Guest Agent。确认安装完成后，在宿主机执行：

```bash
win11-vm-finish-install
```

该命令会切换为硬盘启动，弹出 Windows 安装 ISO 和 VirtIO 驱动 ISO，并在需要时重启虚拟机。命令可以安全地重复执行。随后运行 Windows Update，再通过 virt-manager 创建名为 `clean-install` 的快照。

### 日常使用

从应用菜单启动 **Virtual Machine Manager**，连接 `QEMU/KVM - system` 后即可管理 `win11-pro`。virt-manager 可以启动和关闭虚拟机、打开显示控制台、调整虚拟硬件及创建快照。

不打开图形界面时，可以使用下面的命令：

```bash
# 查看虚拟机
virsh --connect qemu:///system list --all

# 启动并打开显示控制台
virsh --connect qemu:///system start win11-pro
virt-viewer --connect qemu:///system win11-pro

# 请求 Windows 正常关机
virsh --connect qemu:///system shutdown win11-pro
```

虚拟机死机时可以执行下面的命令强制断电，但不要把它当作普通关机使用：

```bash
virsh --connect qemu:///system destroy win11-pro
```

Guest Agent 安装并运行后，libvirt 和 virt-manager 可以读取虚拟机内的 IP 地址，并执行 Guest Agent 支持的管理操作。日常远程使用也可以在 Windows 11 Pro 中启用远程桌面，SPICE 控制台保留用于安装和故障处理。

当前资源参数只在 `win11-vm-create` 创建新虚拟机时生效，不会自动修改已经存在的 `win11-pro`。`/var/lib/libvirt/images` 的 NOCOW 属性同样只对之后创建的磁盘镜像生效。

### 卸载虚拟机

先在 virt-manager 中确认不再需要虚拟机数据，然后删除 `win11-pro`，并勾选删除关联的 `win11-pro.qcow2` 存储卷。此操作不可恢复，但不会影响宿主机文件。
