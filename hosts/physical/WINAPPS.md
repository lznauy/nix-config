# WinApps 连接 Docker 中的 Windows

WinApps 通过 FreeRDP 连接 Docker 容器里的 Windows 虚拟机，并把 Windows 应用显示在 NixOS 桌面上。

## 配置

物理机模块是 `hosts/physical/winapps.nix`，它会安装 `winapps`、`winapps-launcher`，并生成 `~/.config/winapps/winapps.conf`。

当前配置连接本机 Docker 映射的 RDP 端口：

```bash
RDP_USER="lznauy"
RDP_PASS="admin@123"
RDP_IP="127.0.0.1"
RDP_PORT="3389"
WAFLAVOR="docker"
FREERDP_COMMAND="xfreerdp"
```

用户名和密码由 Compose 与 WinApps 配置统一管理。

修改配置后重新构建系统：

```bash
sudo nixos-rebuild switch --flake /home/lznauy/precode/nix-config#physical
```

## 启动 Docker 中的 Windows

WinApps 的 compose 文件位于 `hosts/physical/compose.yaml`。在仓库根目录执行：

```bash
cd hosts/physical
docker compose up -d
```

Docker compose 将 RDP 端口映射到 `127.0.0.1:3389`。使用前确认 Windows 已启动，并且远程桌面服务监听 3389 端口。

## 使用 WinApps

Windows 启动并完成 RDP 配置后，扫描并生成桌面条目：

```bash
winapps-setup --user
```

打开完整 Windows 桌面：

```bash
winapps windows
```

也可以运行 `winapps-launcher`，从桌面菜单启动单个 Windows 应用。停止 Windows：

```bash
cd hosts/physical
docker compose down
```
