# noctalia - Wayland 桌面 Shell(状态栏/通知/启动器等) — v5 配置
{
  config,
  ...
}:
let
  wallpaperDir = "${config.xdg.configHome}/noctalia/wallpapers";
in
{
  programs.noctalia = {
    enable = true;

    settings = {
      # ── Shell ─────────────────────────────────────────────
      shell = {
        # 界面语言
        lang = "zh-CN";
        # 全局字体
        font_family = "Noto Sans CJK SC";
        # UI 整体缩放比例（1.0 = 100%）
        ui_scale = 1.1;
        # 剪贴板自动粘贴: "off" 关闭 / "on" 开启
        clipboard_auto_paste = "off";
        # 着色应用图标（dock/托盘/任务栏/启动器等）以匹配主题
        app_icon_colorize = true;
      };

      # ── Bar ───────────────────────────────────────────────
      bar.main = {
        # 状态栏厚度/高度（逻辑像素）
        thickness = 46;
        # 背景不透明度（0.0 完全透明 ~ 1.0 完全不透明）
        background_opacity = 0.93;
        # bar 两端缩进（主轴方向，默认 180）
        margin_ends = 8;
        # 距屏幕边缘距离（交叉轴方向，默认 10）
        margin_edge = 4;
        # bar 边缘到首尾组件的内边距（默认 14）
        padding = 6;
        # 浮动胶囊布局（控制 bar 整体外形和间距）
        capsule = true;
        # 组件胶囊背景不透明度（0.0 则不显示组件胶囊，但不影响 bar 整体布局）
        capsule_opacity = 0.0;

        # 左侧区域 — 从左到右排列的组件列表
        start = [
          "launcher"        # 启动器/应用菜单
          "wallpaper"       # 壁纸切换
          "clock"           # 时钟
          "ram-text"         # 内存使用显示
          "active_window"   # 当前活动窗口标题
        ];
        # 中间区域 — 居中对齐的组件列表
        center = [ "workspaces" ];
        # 右侧区域 — 从右到左排列的组件列表
        end = [
          "media"           # 媒体播放控制
          "tray"            # 系统托盘
          "notifications"   # 通知
          "network"         # 网络状态
          "battery"         # 电池状态
          "control-center"  # 控制中心
        ];
      };

      # ── Widgets ───────────────────────────────────────────
      widget.clock = {
        # 水平条上的时间格式（strftime 语法）
        format = "{:%H:%M}";
        # 垂直条上的时间格式
        vertical_format = "{:%H:%M}";
        # 鼠标悬停提示的格式
        tooltip_format = "{:%H:%M} %a, %b %d";
      };

      widget.active_window = {
        # 标题最大显示字符数
        max_length = 145;
        # 标题滚动方式: "on_hover" 鼠标悬停时滚动 / "always" 始终滚动 / "off" 关闭
        title_scroll = "on_hover";
        # 显示模式: 图标 + 文字
        display = "icon_and_text";
      };

      widget.workspaces = {
        # 标签模式: "none" 不显示文字 / "id" 显示编号 / "name" 显示名称
        display = "none";
        # 空工作区颜色: "secondary" 次要色
        empty_color = "secondary";
        # 当前聚焦工作区颜色: "primary" 主色
        focused_color = "primary";
        # 有窗口的工作区颜色: "secondary" 次要色
        occupied_color = "secondary";
        # 工作区指示点缩放比例
        pill_scale = 1.0;
      };

      widget.media = {
        # 媒体标题最大显示字符数
        max_length = 160;
        # 标题滚动方式: "on_hover" 鼠标悬停时滚动
        title_scroll = "on_hover";
        # 无媒体播放时是否隐藏: false 始终显示 / true 无媒体时隐藏
        hide_when_no_media = true;
      };

      widget.ram-text = {
        type = "sysmon";
        stat = "ram_pct";
        display = "text";
        show_label = true;
        label_min_width = 48;
      };

      # ── System Monitor ────────────────────────────────────
      system.monitor = {
        # 只启用内存采样，其余设为 0 禁用
        memory_poll_seconds = 2.0;
        cpu_poll_seconds = 0.0;
        network_poll_seconds = 0.0;
        disk_poll_seconds = 0.0;
      };

      widget.tray = {
        # 是否使用抽屉模式: 点击展开而非直接显示所有图标
        drawer = true;
      };

      # ── Wallpaper ─────────────────────────────────────────
      wallpaper = {
        # 壁纸存放目录
        directory = wallpaperDir;
      };
      wallpaper.automation = {
        # 启用自动切换壁纸
        enabled = true;
        # 切换顺序: "random" 随机 / "sequential" 顺序
        order = "random";
      };

      # ── Location ──────────────────────────────────────────
      location = {
        # 关闭自动定位，使用手动地址
        auto_locate = false;
        address = "Xi'an, Shaanxi, China";
      };

      # ── Weather ────────────────────────────────────────────
      weather = {
        # 启用天气服务（控制中心会增加 Weather 标签页）
        enabled = true;
        # 刷新间隔（分钟，默认 30）
        refresh_minutes = 30;
        # 单位: "metric" 公制 / "imperial" 英制
        unit = "metric";
      };

      # ── Calendar ───────────────────────────────────────────
      calendar = {
        # 启用日历服务
        enabled = true;
        # 同步间隔（分钟）
        refresh_minutes = 1440;
        # Google 日历账户（OAuth 授权，无需填密码）
        account.google = {
          type = "google";
          name = "Google 日历";
        };
      };

      # ── Theme ─────────────────────────────────────────────
      theme = {
        # 主题模式: "auto" 随日出日落自动切换亮暗
        mode = "auto";
        # 配色来源: "wallpaper" 从当前默认壁纸生成调色板
        source = "wallpaper";
        # 壁纸取色方案: m3-tonal-spot (Material 3 色调点方案)
        wallpaper_scheme = "m3-tonal-spot";
        # 应用配色模板 — 已安装且有模板的应用
        templates = {
          # 内置模板
          enable_builtin_templates = true;
          builtin_ids = [
            "cava"
            "kitty"
            "gtk3"
            "gtk4"
            "qt"
          ];
          enable_community_templates = true;
          community_ids = [
            "fuzzel"
            "telegram"
            "yazi"
            "zed"
          ];
        };
      };

      # ── Dock ──────────────────────────────────────────────
      dock = {
        # 是否自动隐藏 dock
        auto_hide = true;
      };
    };
  };

  xdg.configFile."noctalia/wallpapers" = {
    source = ../wallpapers;
    recursive = true;
    force = true;
  };
}
