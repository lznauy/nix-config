# Desktop Lyrics

基于 Quickshell 的 Wayland 桌面歌词悬浮层。组件保持透明并浮在普通窗口之上，不占用屏幕布局；只有歌词区域接收鼠标输入，其他区域保持点击穿透。

## 交互

- 默认显示当前歌词与下一句，不再折叠成底部胶囊。
- 鼠标拖动歌词区域可调整位置，松开后按屏幕保存相对坐标。
- 悬停时显示曲目信息、播放/暂停和下一曲按钮。
- 暂停后保留当前歌词；播放器关闭后显示等待状态。
- 每块屏幕创建独立悬浮层，位置分别保存在 XDG_STATE_HOME/quickshell/dynamic-island/。

## 窗口行为

    PanelWindow (WlrLayer.Overlay)
    ├── 全屏透明 surface
    ├── exclusiveZone: -1
    ├── keyboardFocus: None
    ├── mask: 仅 LyricsContent 区域
    └── LyricsContent
        ├── DragHandler
        ├── 当前歌词 + 下一句
        └── 悬停播放控制

全屏 layer-shell surface 只负责提供任意位置坐标系。Region 输入 mask 始终跟随歌词组件，因此不会阻挡歌词以外窗口的点击和滚动。

## Noctalia 主题

Common/Appearance.qml 监听 Noctalia v5 生成的：

    ~/.config/noctalia/colors.json

Material 3 色彩映射：

| Noctalia | 用途 |
|---|---|
| mPrimary | 当前歌词强调线、拖动标记 |
| mOnSurface | 当前歌词 |
| mOnSurfaceVariant | 下一句、曲目信息 |
| mSurfaceVariant | 悬停按钮背景 |
| mOutline | 辅助轮廓 |

主题文件变化后会自动重载，并用 220ms 颜色过渡切换。若 `colors.json` 尚未生成，会自动读取 Noctalia 内置 Starship 模板产生的 `~/.cache/noctalia/starship-palette.toml`；两者都不可用时才回退到 Nord 配色。

歌词本身没有背景。文字使用与前景色反向的细描边，保证覆盖在亮色或暗色应用窗口上时仍可辨认。

主歌词使用霞鹜文楷，曲名和控制信息使用 Noto Sans CJK。悬停时仅控制条显示高不透明度主题承载面，歌词区域继续保持透明。

组件启动后静默待机，仅在当前歌曲的有效歌词加载完成后淡入。无播放器、无曲目、加载中或无歌词时不显示任何提示，也不占用窗口输入区域；暂停时保留当前歌词。

## 歌词获取

    MPRIS track change
      ├── 300ms debounce
      ├── QQ 音乐 API
      ├── 网易云 API fallback
      ├── XDG cache + 文件锁 + 原子写入
      └── JSON lyrics model
           └── 100ms position sync + 二分查找

搜索结果会同时校验曲名、歌手和 Live/Remix 等版本标记，不再直接使用第一条候选；开头的制作名单会被过滤。缓存目录为 XDG_CACHE_HOME/quickshell/dynamic-island/lyrics，未设置时使用 ~/.cache，最多保留 256 条。无歌词结果缓存 10 分钟，避免多屏和重复播放持续请求。

## 目录

    dynamic-island/
    ├── shell.qml
    ├── Common/
    │   ├── Appearance.qml
    │   ├── Paths.qml
    │   └── Sizes.qml
    ├── Content/
    │   └── LyricsContent.qml
    └── scripts/
        └── lyrics_fetcher.py

ClockContent.qml 与 TranslationContent.qml 仍保留为独立组件，但不再挂载到默认歌词悬浮层。

## 依赖

| 组件 | 说明 |
|---|---|
| Quickshell | PanelWindow、MPRIS、FileView、Process |
| Qt 6 | QML、Quick Effects |
| Python 3.8+ | 歌词抓取，仅使用标准库 |
| wlr-layer-shell | 透明 Overlay 与输入区域 |
| Noctalia v5 | 可选动态主题来源 |

## 启动

    qs-island

启动脚本会创建位置状态目录，再加载 shell.qml。
