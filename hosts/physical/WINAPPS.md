# NixOS 上的 WinApps 安装与使用

WinApps 不直接运行 Windows 程序。它通过 FreeRDP 连接正在运行的 Windows 虚拟机，再把 RemoteApp 窗口显示到 NixOS 桌面。当前链路如下：

```text
NixOS / Niri
    │
    ├── WinApps + FreeRDP
    │
    └── libvirt: qemu:///system
            │
            └── win11-pro (Windows 11 Pro)
                    └── Windows 应用
```

Windows 虚拟机必须处于运行状态。WinApps 不是 Wine，也不能在虚拟机关机时单独启动某个 `.exe`。

## 仓库中的配置

WinApps 的 flake input 位于 `flake.nix`：

```nix
winapps = {
  url = "github:winapps-org/winapps";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

物理机通过 `hosts/physical/winapps.nix` 安装 WinApps、WinApps Launcher 和密码询问脚本。`hosts/physical/default.nix` 导入这个模块。

当前连接参数是：

```bash
RDP_USER="10315"
RDP_PASS=""
RDP_DOMAIN=""

RDP_IP=""
RDP_PORT="3389"
VM_NAME="win11-pro"
WAFLAVOR="libvirt"
```

`RDP_IP` 留空时，WinApps 通过 libvirt 自动查找虚拟机地址。当前虚拟机通常使用 `192.168.122.11`，但配置不依赖这个地址固定不变。

密码没有写入 Git 或 Nix store。FreeRDP 首次连接时调用 Zenity 询问密码，随后把密码以 `0600` 权限暂存在：

```text
/run/user/$UID/winapps-rdp-password
```

这是内存中的运行时目录，注销 NixOS 会话后会消失。输错密码时可以手动清除：

```bash
rm -f "${XDG_RUNTIME_DIR}/winapps-rdp-password"
```

应用配置后，生成的 WinApps 配置位于 `~/.config/winapps/winapps.conf`：

```bash
sudo nixos-rebuild switch --flake .#physical
```

## Windows 端准备

Windows 需要 Pro、Enterprise 或 Education 版本。Home 版没有可供 WinApps 使用的远程桌面服务端。

### 启用远程桌面

在 Windows 中以管理员身份打开 PowerShell：

```powershell
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
  -Name fDenyTSConnections -Value 0

Set-Service TermService -StartupType Automatic
Start-Service TermService

Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP"
Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-UDP"
```

检查 3389 端口是否监听：

```powershell
Get-NetTCPConnection -LocalPort 3389 -State Listen
```

在 NixOS 上检查连通性：

```bash
nc -vz 192.168.122.11 3389
```

### 启用 RemoteApp 和目录重定向

libvirt 安装方式需要导入 WinApps 官方的 `RDPApps.reg`。也可以在管理员 PowerShell 中写入关键项：

```powershell
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList" `
  /v fDisabledAllowList /t REG_DWORD /d 1 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
  /v fAllowUnlistedRemotePrograms /t REG_DWORD /d 1 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
  /v fDisableCdm /t REG_DWORD /d 0 /f
```

修改后重启 Windows：

```powershell
Restart-Computer
```

WinApps 会把 Linux 主目录映射为 Windows 中的 `\\tsclient\home`。连接完整桌面后可以检查：

```powershell
Test-Path '\\tsclient\home'
```

结果应为 `True`。

### Microsoft 账户的用户名和密码

当前 Windows 登录使用 Microsoft 账户，但 RDP 用户名填写 `whoami` 返回的本地 SAM 用户名：

```powershell
whoami
```

当前输出类似：

```text
lznauy-nix-win\10315
```

因此 WinApps 使用 `RDP_USER="10315"` 和空的 `RDP_DOMAIN`。直接填写 Microsoft 邮箱会被 FreeRDP 当成 UPN，随后尝试查找邮箱域名对应的 Kerberos KDC。

密码框中输入 Microsoft 账户密码，不是 Windows Hello PIN、指纹或人脸凭据。如果平时只用 PIN，需要在 Windows 的“设置 → 账户 → 登录选项”中关闭“仅允许对此设备上的 Microsoft 账户使用 Windows Hello 登录”，再用 Microsoft 账户密码登录一次。

## 安装 WinApps 桌面条目

Windows 重启后先注销 Windows 用户，保持虚拟机运行。在 NixOS 中运行：

```bash
env -u http_proxy -u https_proxy -u all_proxy \
    -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    winapps-setup
```

这个版本的安装器直接运行 `winapps-setup`，没有 `install` 子命令。

安装到当前用户时选择：

1. `Install`。
2. `Current User`。
3. 按需要选择自动安装或手动选择应用。

安装器显示 Nix store 不是默认安装位置的警告可以忽略。Nix 提供的是只读软件包，WinApps 会在 `~/.local/bin`、`~/.local/share/applications` 和 `~/.local/share/winapps` 下创建当前用户的运行文件和桌面条目。

如果安装器提示 `~/.local/bin` 不在 `PATH`，不要照着提示修改 `.bashrc`。当前 shell 是 Fish，桌面启动器也不依赖这条 Bash 配置。确实需要从终端调用生成的脚本时，可在 Home Manager 中设置：

```nix
home.sessionPath = [ "$HOME/.local/bin" ];
```

## 日常使用

打开完整 Windows 桌面：

```bash
winapps windows
```

打开 WinApps Launcher：

```bash
winapps-launcher
```

直接运行任意 Windows 程序：

```bash
winapps manual 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
```

WorkBuddy 的当前路径是：

```bash
winapps manual 'C:\Users\10315\AppData\Local\Programs\WorkBuddy\WorkBuddy.exe'
```

添加新扫描到的应用，不重装已有条目：

```bash
winapps-setup --user --add-apps
```

清空当前用户的 WinApps 桌面条目：

```bash
winapps-setup --user --uninstall
```

## 为什么有些应用扫描不到

WinApps 不会递归扫描整个 Windows 磁盘。当前扫描脚本只读取：

- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths`；
- UWP 应用；
- Chocolatey shims；
- Scoop shims。

安装在 `%LOCALAPPDATA%`、没有注册到 `App Paths` 的 Electron 应用经常会漏掉。WorkBuddy 就属于这种情况。

可以先在 Windows 中运行程序，再查找真实路径：

```powershell
Get-Process | Where-Object ProcessName -Match 'WorkBuddy' |
  Select-Object ProcessName, Path
```

若希望安装器识别 WorkBuddy，在 Windows 管理员 PowerShell 中注册：

```powershell
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WorkBuddy.exe'
New-Item $key -Force | Out-Null
Set-Item $key -Value 'C:\Users\10315\AppData\Local\Programs\WorkBuddy\WorkBuddy.exe'
```

随后运行 `winapps-setup --user --add-apps`，手动勾选 WorkBuddy。

## 输入法和键盘

WinApps 的 RemoteApp 使用 X11 版 `xfreerdp`，在 Niri/Wayland 下经 XWayland 显示。当前配置没有启用 `/kbd:unicode`：

```bash
RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
```

此前启用 `/kbd:unicode` 后，PowerShell 输入正常，但 WorkBuddy 的 Backspace、输入法切换等控制键异常。普通字符可以通过 Unicode 事件传入，编辑键和组合键在 X11 RemoteApp 中仍可能丢失，因此不再使用这个参数。

若需要对照测试，出现问题的旧配置是：

```bash
RDP_FLAGS="/cert:tofu /sound /microphone +home-drive /kbd:unicode"
```

RemoteApp 对 NixOS 本地 Fcitx 输入法的支持不稳定。Windows 内应安装微软拼音，并在远程窗口中用 Windows 输入法。`Win+Space` 可能被 Niri 拦截，可以在 Windows 中把输入法切换键改为 `Ctrl+Shift`。

完整桌面在 Wayland 会话下会优先使用 SDL FreeRDP。若 `winapps windows` 中键盘正常，而独立 RemoteApp 窗口异常，问题位于 X11 RemoteApp 后端。

## 多余窗口

Electron 和 Chromium 应用常创建启动画面、更新器、辅助窗口或透明窗口。RemoteApp 会把每个 Windows 顶层窗口分别映射成 Niri 窗口，因此 WorkBuddy 之类的应用可能出现一个看似多余的弹框。应用定义中只有一个 EXE 时，这通常不是 WinApps 重复启动。

无法接受这些辅助窗口时，使用完整桌面更稳定：

```bash
winapps windows
```

## Clash 和虚拟机网络

不要为 NixOS 设置全局 `networking.proxy.default`。FreeRDP 会读取 `http_proxy`，把 `192.168.122.11:3389` 送到 Clash HTTP 代理，日志中会出现：

```text
[http_proxy_connect]: Failed to connect to proxy
```

Clash TUN 可以继续使用。执行安装器或排错时，可以临时清除代理环境：

```bash
env -u http_proxy -u https_proxy -u all_proxy \
    -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    winapps-setup
```

Windows 访问外网时可直接使用宿主机 Clash HTTP 代理：

```text
地址：192.168.122.1
端口：7897
```

宿主机只在 `virbr0` 接口放行 7897/TCP，不向物理局域网暴露代理端口。

## 排错记录

WinApps 的连接和扫描日志位于：

```text
~/.local/share/winapps/FreeRDP_Test_*.log
~/.local/share/winapps/FreeRDP_Scan_*.log
~/.local/share/winapps/winapps.log
```

### 3389 端口不通

错误通常是：

```text
NETWORK CONFIGURATION ERROR
Failed to establish a connection with Windows at '192.168.122.11:3389'
```

先检查 VM 是否运行、IP 是否正确，再检查 Windows 的远程桌面服务和防火墙。增加 `PORT_TIMEOUT` 无法修复没有监听的端口。

### FreeRDP 走了 Clash 代理

日志出现 `http_proxy_connect` 或 `Parsed proxy configuration` 时，当前会话仍带有代理环境变量。删除 NixOS 全局代理配置后，需要注销并重新登录；也可以用前面的 `env -u` 命令临时清除。

### 证书指纹变化

虚拟机重装、RDP 证书变化或同一 IP 换过虚拟机时，可以删除旧证书：

```bash
rm -f ~/.config/freerdp/server/192.168.122.11_3389.pem
```

只应在确认目标确实是自己的 `win11-pro` 后执行。

### NLA 登录失败

日志中的关键错误是：

```text
ERRCONNECT_LOGON_FAILURE
```

按顺序检查用户名、域和密码。当前组合是本地 SAM 用户 `10315`、空域、Microsoft 账户密码。不要使用 PIN，也不要把邮箱直接写入 `RDP_USER`。

### Kerberos KDC 错误

以下错误表示 FreeRDP 把用户名误解析成域账户：

```text
Cannot find KDC for realm "QQ.COM"
Cannot find KDC for realm "LZNAUY-NIX-WIN"
```

个人 Microsoft 账户在这台 VM 上使用 `whoami` 返回的本地用户名和空域，避免把邮箱域名或计算机名写进 `RDP_DOMAIN`。

### 摄像头插件导致连接后失败

曾经使用过以下参数：

```text
/video /dvc:rdpecam
```

当前 NixOS 的 FreeRDP 构建没有 `rdpecam` 插件，日志会出现：

```text
Failed to load channel rdpecam
ERRCONNECT_POST_CONNECT_FAILED
```

删除这两个参数即可。声音和麦克风可以继续保留。

### 应用扫描失败

如果 RDP 已登录，但 WinApps 等不到 `FreeRDP_Connection_Test` 或 `installed` 文件，检查两件事：Windows 是否已经应用 `RDPApps.reg`，以及 `\\tsclient\home` 是否可访问。盲目增加 `RDP_TIMEOUT` 或 `APP_SCAN_TIMEOUT` 只会延后报错。

### 密码框重复出现

安装过程会启动多次 FreeRDP，连接测试和应用扫描各用一个进程。普通 askpass 脚本会重复询问密码，第二次输入为空时扫描会报 `ERRCONNECT_LOGON_FAILURE`。当前模块把首次输入暂存在 `/run/user/$UID`，后续连接复用同一密码。

## 资源占用

WinApps 只负责 RDP 集成，内存主要由 Windows VM 占用。当前 `win11-pro` 使用 4 GiB 启动内存、5 GiB 上限。宿主机通过 zram 和 NVMe swap 缓解持续内存压力。不使用 Windows 应用时，应正常关闭或暂停虚拟机。
