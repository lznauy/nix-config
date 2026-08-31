import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string configHome: {
        var configured = Quickshell.env("XDG_CONFIG_HOME")
        return configured !== "" ? configured : Quickshell.env("HOME") + "/.config"
    }
    readonly property string cacheHome: {
        var configured = Quickshell.env("XDG_CACHE_HOME")
        return configured !== "" ? configured : Quickshell.env("HOME") + "/.cache"
    }
    readonly property string noctaliaColorsPath: configHome + "/noctalia/colors.json"
    readonly property string noctaliaPalettePath: cacheHome + "/noctalia/starship-palette.toml"

    property string activeSource: "fallback"
    property bool initialThemeLoaded: false

    // Noctalia's Material 3 color roles. These defaults match Noctalia v5.
    property color primary: "#fff59b"
    property color primaryForeground: "#0e0e43"
    property color secondary: "#a9aefe"
    property color error: "#fd4663"
    property color errorForeground: "#0e0e43"
    property color surface: "#070722"
    property color surfaceForeground: "#f3edf7"
    property color surfaceVariant: "#11112d"
    property color surfaceVariantForeground: "#7c80b4"
    property color outline: "#21215f"
    property color shadow: "#070722"
    property color hover: "#9bfece"
    property color hoverForeground: "#0e0e43"

    readonly property bool darkMode: luminance(surface) < 0.5
    readonly property string fontFamily: "Noto Sans CJK SC"

    // Mirrors Noctalia Style.qml's compact utility scale.
    readonly property real fontSizeXS: 9
    readonly property real fontSizeS: 10
    readonly property real fontSizeM: 11
    readonly property real fontSizeL: 13
    readonly property real fontSizeXL: 16
    readonly property real spacingXS: 4
    readonly property real spacingS: 6
    readonly property real spacingM: 9
    readonly property real spacingL: 13
    readonly property real spacingXL: 18
    readonly property real radiusXS: 8
    readonly property real radiusS: 12
    readonly property real radiusM: 16
    readonly property real radiusL: 20
    readonly property int animationFaster: 75
    readonly property int animationFast: 150

    function luminance(value) {
        return value.r * 0.2126 + value.g * 0.7152 + value.b * 0.0722
    }

    function withAlpha(value, alpha) {
        return Qt.rgba(value.r, value.g, value.b, alpha)
    }

    function validColor(value) {
        return typeof value === "string" && /^#[0-9a-fA-F]{6,8}$/.test(value)
    }

    function applyNoctaliaPalette(data) {
        var required = [
            "mPrimary", "mOnPrimary", "mSecondary", "mError", "mSurface",
            "mOnSurface", "mSurfaceVariant", "mOnSurfaceVariant", "mOutline", "mShadow"
        ]
        for (var index = 0; index < required.length; index++) {
            if (!validColor(data && data[required[index]])) return false
        }

        primary = data.mPrimary
        primaryForeground = data.mOnPrimary
        secondary = data.mSecondary
        error = data.mError
        errorForeground = validColor(data.mOnError) ? data.mOnError : data.mOnPrimary
        surface = data.mSurface
        surfaceForeground = data.mOnSurface
        surfaceVariant = data.mSurfaceVariant
        surfaceVariantForeground = data.mOnSurfaceVariant
        outline = data.mOutline
        shadow = data.mShadow
        hover = validColor(data.mHover) ? data.mHover : data.mPrimary
        hoverForeground = validColor(data.mOnHover) ? data.mOnHover : data.mOnPrimary
        activeSource = "json"
        initialThemeLoaded = true
        return true
    }

    function tomlColor(data, key) {
        var match = new RegExp("^\\s*" + key + "\\s*=\\s*\"(#[0-9a-fA-F]{6,8})\"", "m").exec(data)
        return match ? match[1] : ""
    }

    function applyStarshipPalette(data) {
        if (activeSource === "json") return true

        var palette = {
            primary: tomlColor(data, "blue"),
            primaryForeground: tomlColor(data, "base"),
            secondary: tomlColor(data, "magenta"),
            error: tomlColor(data, "red"),
            surface: tomlColor(data, "base"),
            surfaceForeground: tomlColor(data, "text"),
            surfaceVariant: tomlColor(data, "surface1"),
            surfaceVariantForeground: tomlColor(data, "subtext0"),
            outline: tomlColor(data, "overlay1"),
            hover: tomlColor(data, "green")
        }
        for (var key in palette) {
            if (!validColor(palette[key])) return false
        }

        primary = palette.primary
        primaryForeground = palette.primaryForeground
        secondary = palette.secondary
        error = palette.error
        errorForeground = palette.primaryForeground
        surface = palette.surface
        surfaceForeground = palette.surfaceForeground
        surfaceVariant = palette.surfaceVariant
        surfaceVariantForeground = palette.surfaceVariantForeground
        outline = palette.outline
        shadow = "#000000"
        hover = palette.hover
        hoverForeground = palette.primaryForeground
        activeSource = "starship"
        initialThemeLoaded = true
        return true
    }

    Behavior on primary { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on primaryForeground { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on secondary { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on error { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on surface { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on surfaceForeground { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on surfaceVariant { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on surfaceVariantForeground { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on outline { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }
    Behavior on hover { enabled: root.initialThemeLoaded; ColorAnimation { duration: root.animationFast; easing.type: Easing.OutCubic } }

    property FileView noctaliaColors: FileView {
        path: root.noctaliaColorsPath
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoadFailed: {
            if (root.activeSource === "json") root.activeSource = "fallback"
            if (root.activeSource === "fallback") root.noctaliaPalette.reload()
        }
        onLoaded: {
            try {
                if (!root.applyNoctaliaPalette(JSON.parse(text()))) {
                    if (root.activeSource === "json") root.activeSource = "fallback"
                    root.noctaliaPalette.reload()
                }
            } catch (error) {
                if (root.activeSource === "json") root.activeSource = "fallback"
                if (root.activeSource === "fallback") root.noctaliaPalette.reload()
                console.warn("[todo] invalid Noctalia colors.json", error)
            }
        }
    }

    property FileView noctaliaPalette: FileView {
        path: root.noctaliaPalettePath
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: {
            if (!root.applyStarshipPalette(text())) root.initialThemeLoaded = true
        }
        onLoadFailed: root.initialThemeLoaded = true
    }

    property Timer themeProbe: Timer {
        interval: 2000
        repeat: true
        running: root.activeSource !== "json"
        onTriggered: root.noctaliaColors.reload()
    }
}
