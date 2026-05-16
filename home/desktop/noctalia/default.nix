# noctalia-shell - Wayland 桌面 Shell(状态栏/通知/启动器等)
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    colors = {
      # Polar Night - 背景
      mSurface = "#2E3440";
      mSurfaceVariant = "#3B4252";
      mShadow = "#000000";
      mOutline = "#4C566A";
      # Snow Storm - 文字
      mOnSurface = "#D8DEE9";
      mOnSurfaceVariant = "#81A1C1";
      # Frost - 强调色
      mPrimary = "#5E81AC";
      mOnPrimary = "#ECEFF4";
      mSecondary = "#4C566A";
      mOnSecondary = "#D8DEE9";
      mTertiary = "#88C0D0";
      mOnTertiary = "#2E3440";
      # Aurora - 功能色
      mError = "#BF616A";
      mOnError = "#ECEFF4";
    };
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        # "network-manager-vpn".enabled = true;
      };
      version = 2;
    };
    settings = {
      general = {
        language = "zh-CN";
      };
      ui = {
        language = "zh-CN";
        fontDefault = "Noto Sans CJK SC";
        fontFixed = "JetBrainsMono Nerd Font";
        fontDefaultScale = 1.1;
        fontFixedScale = 1.1;
      };
      bar = {
        # 兼容 Migration45 迁移脚本，否则 barType 会被覆盖为 "simple"
        floating = true;
        barType = "floating"; # 任务栏类型: simple/floating/framed
        position = "top"; # 位置: top/bottom/left/right
        density = "spacious"; # 密度: compact(紧凑)/comfortable(舒适)/spacious(宽松)
        displayMode = "always_visible"; # 显示模式: always_visible(始终显示)/auto_hide(自动隐藏)/hidden(隐藏)
        fontScale = 1.0; # 字体缩放
        marginVertical = 12; # 垂直外边距
        marginHorizontal = 12; # 水平外边距
        contentPadding = 6; # 内容内边距
        backgroundOpacity = 0.93; # 背景透明度 (0-1)
        frameThickness = 8; # 边框厚度
        frameRadius = 12; # 圆角半径
        outerCorners = true; # 只在外角圆角
        showCapsule = true; # 显示胶囊/药丸形状
        capsuleOpacity = 1; # 胶囊透明度
        capsuleColorKey = "none"; # 胶囊颜色 (none=默认)
        showOutline = false; # 显示轮廓
        hideOnOverview = false; # 概览时隐藏
        autoHideDelay = 500; # 自动隐藏延迟 (毫秒)
        autoShowDelay = 150; # 自动显示延迟 (毫秒)
        useSeparateOpacity = false; # 使用独立透明度
        widgetSpacing = 6; # 组件间距
        monitors = [ ]; # 各显示器配置列表
        screenOverrides = [ ]; # 屏幕覆盖设置
        widgets = {
          left = [
            {
              id = "Launcher";
            }
            {
              id = "WallpaperSelector";
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm"; # 水平格式
              formatVertical = "HH:mm"; # 垂直格式
              tooltipFormat = "HH:mm ddd, MMM dd"; # 提示格式
              clockColor = "none"; # 颜色 (none=默认)
              useCustomFont = false; # 使用自定义字体
              customFont = ""; # 自定义字体
            }
            {
              id = "SystemMonitor";
              compactMode = true;
              diskPath = "/";
              iconColor = "none";
              showCpuFreq = false;
              showCpuTemp = false;
              showCpuUsage = true;
              showDiskAvailable = false;
              showDiskUsage = false;
              showDiskUsageAsPercent = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = true;
              showSwapUsage = false;
              textColor = "none";
              useMonospaceFont = true;
              usePadding = false;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = false; # 是否给图标着色
              hideMode = "hidden"; # 隐藏模式 (hidden/compact/icon)
              maxWidth = 145; # 最大宽度
              scrollingMode = "hover"; # 滚动模式 (hover/auto/scroll)
              showIcon = true; # 显示窗口图标
              textColor = "none"; # 文字颜色 (none=默认)
              useFixedWidth = false; # 使用固定宽度
            }
          ];
          center = [
            {
              id = "Workspace";
              characterCount = 2; # 工作区名称字符数限制
              colorizeIcons = false; # 是否给图标着色
              emptyColor = "secondary"; # 空闲工作区颜色
              enableScrollWheel = true; # 启用滚轮切换工作区
              focusedColor = "primary"; # 聚焦工作区颜色
              followFocusedScreen = false; # 跟随聚焦的屏幕
              groupedBorderOpacity = 1; # 分组边框透明度
              hideUnoccupied = false; # 隐藏空闲工作区
              iconScale = 0.8; # 图标缩放比例
              labelMode = "none"; # 标签显示模式 (none/index/name)
              occupiedColor = "secondary"; # 占用工作区颜色
              pillSize = 0.6; # 药丸/圆角大小比例
              showApplications = false; # 在概览中显示应用
              showBadge = true; # 显示徽章
              showLabelsOnlyWhenOccupied = true; # 只在有窗口时显示标签
              unfocusedIconsOpacity = 1; # 非聚焦工作区图标透明度
            }
          ];
          right = [
            {
              id = "MediaMini";
              compactMode = false; # 紧凑模式
              compactShowAlbumArt = true; # 紧凑模式显示专辑封面
              compactShowVisualizer = false; # 紧凑模式显示可视化器
              hideMode = "hidden"; # 隐藏模式 (hidden/compact/icon)
              hideWhenIdle = false; # 空闲时隐藏
              maxWidth = 160; # 最大宽度
              panelShowAlbumArt = true; # 面板显示专辑封面
              panelShowVisualizer = true; # 面板显示可视化器
              scrollingMode = "hover"; # 滚动模式 (hover/auto/scroll)
              showAlbumArt = false; # 显示专辑封面
              showArtistFirst = true; # 先显示艺术家再显示标题
              showProgressRing = true; # 显示进度环
              showVisualizer = false; # 显示可视化器
              textColor = "none"; # 文字颜色 (none=默认)
              useFixedWidth = false; # 使用固定宽度
              visualizerType = "linear"; # 可视化器类型 (linear/circular)
            }
            {
              id = "Tray";
              blacklist = [ ]; # 黑名单应用列表
              chevronColor = "none"; # 箭头颜色 (none=默认)
              colorizeIcons = false; # 给图标着色
              drawerEnabled = true; # 启用抽屉
              hidePassive = false; # 隐藏被动通知的应用
              pinned = [ ]; # 固定的应用列表
            }
            {
              id = "Volume";
              displayMode = "alwaysShow"; # 显示模式 (alwaysShow/hidden/iconOnly)
              iconColor = "none"; # 图标颜色 (none=默认)
              textColor = "none"; # 文字颜色 (none=默认)
              middleClickCommand = "pwvucontrol || pavucontrol"; # 中键点击命令
            }
            {
              id = "Brightness";
              applyToAllMonitors = false; # 应用到所有显示器
              displayMode = "alwaysShow"; # 显示模式
              iconColor = "none"; # 图标颜色 (none=默认)
              textColor = "none"; # 文字颜色 (none=默认)
            }
            {
              id = "NotificationHistory";
              hideWhenZero = false; # 计数为零时隐藏
              hideWhenZeroUnread = false; # 无未读时隐藏
              iconColor = "none"; # 图标颜色 (none=默认)
              showUnreadBadge = true; # 显示未读徽章
              unreadBadgeColor = "primary"; # 未读徽章颜色
            }
            {
              id = "Network";
            }
            {
              id = "Battery";
              deviceNativePath = ""; # 设备原生路径
              displayMode = "alwaysShow"; # 显示模式 (alwaysShow/hidden/iconOnly)
              hideIfIdle = false; # 空闲时隐藏
              hideIfNotDetected = true; # 未检测到时隐藏
              showNoctaliaPerformance = true; # 显示性能提示
              showPowerProfiles = true; # 显示电源模式
            }
            {
              id = "ControlCenter";
              colorizeDistroLogo = false; # 着色发行版Logo
              colorizeSystemIcon = "none"; # 着色系统图标 (none=默认)
              customIconPath = ""; # 自定义图标路径
              enableColorization = false; # 启用着色
              icon = "noctalia"; # 图标名称
              useDistroLogo = true; # 使用发行版Logo
            }
          ];
        };
      };
      wallpaper = {
        enabled = true;
        overviewEnabled = true;
        useSolidColor = false;
        directory = "${config.xdg.configHome}/noctalia/wallpapers";
        viewMode = "crop";
        wallpaperChangeMode = "random";
      };
      appLauncher = {
        enableClipboardHistory = false; # 启用剪贴板历史
        autoPasteClipboard = false; # 自动粘贴剪贴板内容
        enableClipPreview = true; # 启用剪贴板预览
        clipboardWrapText = true; # 剪贴板文字自动换行
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store"; # 文本剪贴板监控命令
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store"; # 图片剪贴板监控命令
        enableClipboardSmartIcons = true; # 智能剪贴板图标
        enableClipboardChips = true; # 剪贴板芯片
        enableSettingsSearch = true; # 启用设置搜索
        enableWindowsSearch = true; # 启用窗口搜索
        enableSessionSearch = true; # 启用会话搜索
        customLaunchPrefixEnabled = false; # 启用自定义启动前缀
        customLaunchPrefix = ""; # 自定义启动前缀
        terminalCommand = "alacritty -e"; # 终端命令
        position = "center"; # 位置: center/left/right
        density = "default"; # 密度: default/compact/comfortable
        viewMode = "list"; # 视图模式: list/grid
        showCategories = true; # 显示分类
        iconMode = "tabler"; # 图标模式: native/tabler 等
        showIconBackground = false; # 显示图标背景
        sortByMostUsed = true; # 按使用频率排序
        pinnedApps = [ ]; # 固定应用列表
        ignoreMouseInput = false; # 忽略鼠标输入
        overviewLayer = false; # 概览层显示
        screenshotAnnotationTool = ""; # 截图标注工具
      };
      colorSchemes = {
        darkMode = true;
      };
      network = {
        wifiEnabled = true; # 启用 WiFi
        airplaneModeEnabled = false; # 飞行模式
        bluetoothRssiPollingEnabled = false; # 蓝牙 RSSI 轮询
        bluetoothRssiPollIntervalMs = 10000; # 蓝牙 RSSI 轮询间隔 (毫秒)
        bluetoothHideUnnamedDevices = false; # 隐藏未命名蓝牙设备
        bluetoothDetailsViewMode = "grid"; # 蓝牙详情视图: grid/list
        wifiDetailsViewMode = "grid"; # WiFi 详情视图: grid/list
        disableDiscoverability = false; # 禁用被发现
      };
      dock = {
        enabled = false; # 启用停靠栏
        position = "bottom"; # 位置 (top/bottom/left/right)
        displayMode = "auto_hide"; # 显示模式 (always_visible/auto_hide/hidden)
        dockType = "floating"; # 类型 (docked/floating/auto)
        size = 1; # 大小比例
        floatingRatio = 1; # 浮动比例
        backgroundOpacity = 1; # 背景透明度
        animationSpeed = 1; # 动画速度
        pinnedApps = [ ]; # 固定的应用列表
        pinnedStatic = false; # 固定应用位置不变
        inactiveIndicators = false; # 非活动指示器
        deadOpacity = 0.6; # 停用透明度
        colorizeIcons = false; # 给图标着色
        monitors = [ ]; # 显示的显示器列表
        onlySameOutput = true; # 只在相同输出显示
        showFrameIndicator = true; # 显示边框指示器
        sitOnFrame = false; # 坐在边框上
      };
    };
  };

  xdg.configFile."noctalia/wallpapers" = {
    source = ../wallpapers;
    recursive = true;
    force = true;
  };
}
