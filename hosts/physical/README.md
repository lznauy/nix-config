## Windows 11 Pro 办公虚拟机

宿主机的 KVM/libvirt、virt-manager 和软件 TPM 配置位于 `virtualisation.nix`。现有 Windows 11 Pro 虚拟机名为 `win11-pro`，由系统级 libvirt 连接 `qemu:///system` 持久管理，虚拟机数据保存在 `/var/lib/libvirt/images`。

```text
virt-manager
     │
     ▼
  libvirtd
     │
     ▼
  QEMU/KVM
```

### 管理虚拟机

从应用菜单启动 **Virtual Machine Manager**，连接 `QEMU/KVM - System` 后即可管理 `win11-pro`：

- 启动、正常关机和重启；
- 打开 SPICE 显示控制台；
- 调整内存、CPU、磁盘、网络和 USB 设备；
- 挂载或弹出 ISO；
- 创建及恢复快照；
- 必要时编辑 libvirt XML。

虚拟机的定义、磁盘和快照是 libvirt 管理的可变状态，不由 NixOS 配置重建或覆盖。删除 NixOS 模块、切换系统代际或运行 `nixos-rebuild` 都不会删除现有虚拟机。

当前内存配置为 4 GiB 启动、5 GiB 上限。Windows 内应保留 VirtIO 驱动和 QEMU Guest Agent，以支持内存 balloon、网络、磁盘及宿主机状态检测。

### WinApps

`winapps.nix` 将 WinApps 连接到 `win11-pro`。安装、Windows 端配置、应用添加、日常使用和排错记录见 [WINAPPS.md](./WINAPPS.md)。

### 备份与删除

重要数据应在 virt-manager 中通过快照或磁盘备份单独保护。需要删除虚拟机时，在 virt-manager 中确认目标为 `win11-pro`，并明确决定是否同时删除关联磁盘；删除磁盘不可恢复。
