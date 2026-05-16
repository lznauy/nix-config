# Dynamic Island

一个基于 Quickshell 的 Wayland 桌面歌词/时钟组件，灵感来自 Apple Dynamic Island。悬浮在屏幕底部，折叠时是一个小药丸，播放音乐时自动展开显示滚动歌词。

## 目录结构

```
dynamic-island/
├── shell.qml                        # 主入口：面板窗口、状态机、播放器管理
├── Common/
│   ├── qmldir                       # 模块声明（singleton 注册）
│   ├── Appearance.qml               # 颜色（Nord 调色板）
│   ├── Animations.qml               # 贝塞尔曲线 & 动画参数（暂未使用）
│   ├── DynamicIslandMotion.qml      # 弹簧物理参数（spring/mass/damping）
│   ├── Sizes.qml                    # 字体栈
│   └── Paths.qml                    # 路径解析
├── Content/
│   ├── qmldir                       # 模块声明
│   ├── ClockContent.qml             # 折叠态时钟（日期 + 翻页数字表）
│   └── LyricsContent.qml            # 歌词获取 & 同步显示
└── scripts/
    └── lyrics_fetcher.py            # 歌词抓取（QQ音乐 → 网易云 → 回退）
```

## 架构

```
┌─────────────────────────────────────────────────────┐
│  PanelWindow (WlrLayershell.Top, exclusiveZone: -1) │
│  ┌───────────────────────────────────────────────┐  │
│  │  maskContainer                               │  │
│  │  ┌─────────────────────────────────────────┐ │  │
│  │  │  ClippingRectangle (root)               │ │  │
│  │  │  • 状态机：collapsed ⇄ lyrics            │ │  │
│  │  │  • 弹簧动画：width / height / radius      │ │  │
│  │  │  • MPRIS 信号 & 轮询双通道               │ │  │
│  │  │  ┌──────────────┐ ┌──────────────────┐  │ │  │
│  │  │  │ ClockContent │ │ LyricsContent    │  │ │  │
│  │  │  │ • 吸顶       │ │ • 歌词抓取(Process)│ │ │  │
│  │  │  │ • 翻页时钟   │ │ • 时间同步(Timer) │  │ │  │
│  │  │  └──────────────┘ └──────────────────┘  │ │  │
│  │  └─────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## 状态机

```
          hover ──────────────┐
            │                 │
   ┌────────▼────────┐       ┌▼─────────────────┐
   │  collapsed (4px) │       │ collapsed-hover  │
   │  无内容          │       │ 时钟 + 日期 (32px)│
   └────────┬────────┘       └────────┬──────────┘
            │ click / 检测到播放       │ click
            ▼                         ▼
   ┌──────────────────────────────────────────┐
   │  lyrics (展开)                            │
   │  专辑封面 + 滚动歌词 (宽度自适应)           │
   │  Esc / 点击 → 折叠（autoDismissed = true） │
   │  切歌 → 自动展开（重置 autoDismissed）     │
   └──────────────────────────────────────────┘
```

## 运行逻辑

### 1. 播放器发现

| 层级 | 机制 | 作用 |
|------|------|------|
| 慢轮询 | `playerPollTimer`（2s） | 发现新播放器、移除已离线的 |
| 信号 | `Connections` 监听 `isPlayingChanged` / `trackChanged` | 切歌、暂停立即响应（<100ms） |

找到正在播放的 player 后，`refreshPlayers()` 将其设为 `currentPlayer`，`Connections` 自动切换到新 player 继续监听。

### 2. 歌词获取（LyricsContent）

```
trackTitle 变化
  │
  ├─ 300ms debounce（防止快速切歌抖动）
  │
  ├─ 杀死旧 Process，重置 fetchValid 标志
  │
  ├─ 启动 lyrics_fetcher.py（Python）
  │     ├─ 查本地缓存 /tmp/qs_lyrics_cache
  │     ├─ 缓存未命中 → QQ音乐 API（3s 超时）
  │     ├─ QQ音乐失败 → 网易云 API（3s 超时）
  │     └─ 都失败 → "暂无歌词"
  │
  ├─ 10s 超时保护（fetchTimeout Timer）
  │     └─ 超时 → "歌词获取超时"，fetchValid = false 防止遗漏 stdout 覆盖
  │
  └─ 解析 JSON → 更新 lyricsModel → ListView 渲染
```

`fetchValid` 守卫确保：
- 超时后的残留 stdout 不覆盖"获取超时"提示
- 切歌后的旧请求输出不污染新歌歌词
- `onRead` 只处理一次（处理完置 false）

### 3. 歌词同步

```
syncTimer（100ms）
  │
  ├─ 读取 player.position（微秒/秒自适应）
  │
  ├─ 遍历 lyricsModel 找到当前行
  │     └─ 向前看 0.5s 避免歌词"跟不上"
  │
  └─ 更新 currentLineIndex → ListView.currentIndex
       └─ highlightMoveDuration: 400ms 滚动动画
```

### 4. 宽度自适应

每行歌词的 `implicitWidth` 不同。当 `isCurrent` 变化时，`lyricsTextWidth` 取**历史最大值**，保证同一首歌内 pill 宽度只增不减（避免宽度抖动）。切歌时重置为 350。

### 5. 动画系统

| 属性 | 阻尼（展开） | 阻尼（缩小） | 效果 |
|------|------------|------------|------|
| width | 0.7（弹） | 0.8（稳） | 展开时更有弹性 |
| height | 0.7 | 0.8 | 同上 |
| radius | 0.7 | 0.8 | 圆角同步收放 |

弹簧物理参数（`DynamicIslandMotion`）：spring=5.0, mass=3.6, epsilon=0.01

## 多屏支持

`Variants { model: Quickshell.screens }` 为每个屏幕创建独立实例。每个实例独立运行（各自维护 `currentPlayer`、`showLyrics` 等状态）。歌词缓存（`/tmp/qs_lyrics_cache`）跨实例共享，避免重复网络请求。

## 依赖

| 组件 | 说明 |
|------|------|
| Quickshell (>= 0.0.10) | PanelWindow, Mpris, Process, ClippingRectangle |
| Qt 6 (>= 6.7) | QML, Quick.Effects |
| Python 3.8+ | 歌词抓取脚本 |
| wayland (wlr-layer-shell) | 面板悬浮 |

Python 端依赖标准库（`urllib`, `hashlib`, `base64`, `json`），无额外 pip 包。

## Nix 部署

```nix
# home-manager 模块
xdg.configFile = {
  "quickshell/dynamic-island/shell.qml" = { source = ./shell.qml; force = true; };
  # ... 其他文件
};

home.packages = [
  (pkgs.writeShellScriptBin "qs-island" ''
    exec ${pkgs.quickshell}/bin/quickshell \
      --path ${config.xdg.configHome}/quickshell/dynamic-island/shell.qml
  '')
];
```

启动：`qs-island`（自动加入 autostart 或手动执行）。
