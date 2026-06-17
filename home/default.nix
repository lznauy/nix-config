{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.stateVersion = "26.05";

  imports = [
    ./stylix/default.nix
    ./base/fcitx5.nix
    ./desktop/niri/default.nix
    ./desktop/noctalia/default.nix
    ./desktop/hyprlock/default.nix
    ./desktop/quickshell/todo
    ./desktop/quickshell/dynamic-island
    ./desktop/fuzzel.nix
    ./desktop/kitty.nix
    ./desktop/gtk.nix
    ./shell/default.nix
    ./xdg/default.nix
    ./xdg/mime.nix
    ./xdg/desktop-files.nix
    ./xdg/autostart.nix
    ./programs/qutebrowser/default.nix
    ./programs/ai/default.nix
    ./programs/apps.nix
    ./programs/qq
    ./programs/onlyoffice.nix
    ./programs/wechat.nix
    ./programs/zed.nix
    ./programs/asciinema.nix
    ./programs/btm.nix
    ./programs/devshell/home.nix
    ./programs/fastfetch.nix
    ./programs/git.nix
    ./programs/nh.nix
    ./programs/nixvim/default.nix
    ./programs/system-tui.nix
  ];

  home.packages = with pkgs; [
    gifski # 高质量 GIF 编码器
    libwebp # WebP 图像格式工具集(cwebp/dwebp/gif2webp)
    ffmpeg # 多媒体处理框架
    openssl # 加密库与命令行工具

    net-tools # 网络配置工具集(ifconfig 等)
    translate-shell # 终端翻译工具
    libcaca # 文本模式图形渲染库
    yq # YAML/TOML 命令行处理器
    jq # JSON 命令行处理器
    zip # ZIP 压缩工具
    unzip # ZIP 解压工具
    p7zip # 7z 压缩/解压工具
    duf # 磁盘用量可视化工具
    iotop # I/O 监控工具
    cloc # 代码行数统计工具
    doggo # 现代 DNS 查询工具
    quien # 更好的 WHOIS 查询工具
    dive # Docker 镜像层分析工具
    lsof # 查看打开文件工具
    wget # HTTP 下载工具
    posting # postman终端版
    gh-dash # github终端版
    pipx # Python CLI 工具隔离安装器

    tree # 目录树展示工具
    fd # 快速文件查找工具
    ripgrep # 高性能文本搜索工具
    bat # 带语法高亮的 cat 替代品
    chafa # 终端图像渲染工具
    yazi # 终端文件管理器
    tmux # 终端复用器
    gonzo # 日志分析工具
    age # age 加密工具
    sops # 密钥加密管理工具
    nixfmt-tree # Nix 代码格式化工具
    just # 命令运行器(Makefile 替代品)
    fzf # 模糊搜索工具
    lazygit # 终端 Git 客户端
    hugo # 静态网站生成器
    mkcert # 本地 HTTPS 证书生成工具
    comma # 使用逗号临时运行未安装的程序
    wayscrollshot # Wayland 滚动截图工具
    upx # 可执行文件压缩工具
    blueman # 蓝牙管理 GUI
    cava # 终端音量显示
    pulseaudio # PulseAudio 客户端工具 (pactl, parec)
  ];
}
