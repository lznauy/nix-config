pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
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
    readonly property bool usingNoctalia: activeSource !== "fallback"
    readonly property bool usingJsonPalette: activeSource === "json"

    property color primary: "#88C0D0"
    property color primaryForeground: "#2E3440"
    property color secondary: "#81A1C1"
    property color surface: "#2E3440"
    property color surfaceVariant: "#3B4252"
    property color foreground: "#D8DEE9"
    property color foregroundMuted: "#E5E9F0"
    property color outline: "#4C566A"
    property color shadow: "#000000"
    property color error: "#BF616A"

    readonly property bool darkMode: luminance(surface) < 0.5

    function luminance(colorValue) {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152 + colorValue.b * 0.0722
    }

    function withAlpha(colorValue, alpha) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alpha)
    }

    function isColorValue(value) {
        return typeof value === "string" && /^#[0-9a-fA-F]{6,8}$/.test(value)
    }

    function applyFallbackPalette() {
        root.primary = "#88C0D0"
        root.primaryForeground = "#2E3440"
        root.secondary = "#81A1C1"
        root.surface = "#2E3440"
        root.surfaceVariant = "#3B4252"
        root.foreground = "#D8DEE9"
        root.foregroundMuted = "#E5E9F0"
        root.outline = "#4C566A"
        root.shadow = "#000000"
        root.error = "#BF616A"
        root.activeSource = "fallback"
    }

    function applyNoctaliaPalette(data) {
        var requiredKeys = [
            "mPrimary", "mOnPrimary", "mSecondary", "mSurface", "mSurfaceVariant",
            "mOnSurface", "mOnSurfaceVariant", "mOutline", "mShadow", "mError"
        ]
        for (var index = 0; index < requiredKeys.length; index++) {
            if (!root.isColorValue(data && data[requiredKeys[index]])) return false
        }

        root.primary = data.mPrimary
        root.primaryForeground = data.mOnPrimary
        root.secondary = data.mSecondary
        root.surface = data.mSurface
        root.surfaceVariant = data.mSurfaceVariant
        root.foreground = data.mOnSurface
        root.foregroundMuted = data.mOnSurfaceVariant
        root.outline = data.mOutline
        root.shadow = data.mShadow
        root.error = data.mError
        root.activeSource = "json"
        return true
    }

    function tomlColor(data, key) {
        var match = new RegExp("^\\s*" + key + "\\s*=\\s*\"(#[0-9a-fA-F]{6,8})\"", "m").exec(data)
        return match ? match[1] : ""
    }

    function applyStarshipPalette(data) {
        var palette = {
            primary: tomlColor(data, "blue"),
            primaryForeground: tomlColor(data, "base"),
            secondary: tomlColor(data, "magenta"),
            surface: tomlColor(data, "base"),
            surfaceVariant: tomlColor(data, "surface1"),
            foreground: tomlColor(data, "text"),
            foregroundMuted: tomlColor(data, "subtext0"),
            outline: tomlColor(data, "overlay1"),
            error: tomlColor(data, "red")
        }
        for (var key in palette) {
            if (!root.isColorValue(palette[key])) return false
        }

        root.primary = palette.primary
        root.primaryForeground = palette.primaryForeground
        root.secondary = palette.secondary
        root.surface = palette.surface
        root.surfaceVariant = palette.surfaceVariant
        root.foreground = palette.foreground
        root.foregroundMuted = palette.foregroundMuted
        root.outline = palette.outline
        root.error = palette.error
        root.shadow = "#000000"
        root.activeSource = "starship"
        return true
    }

    Behavior on primary { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on primaryForeground { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on secondary { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on surface { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on surfaceVariant { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on foreground { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on foregroundMuted { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on outline { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }

    FileView {
        id: noctaliaColors
        path: root.noctaliaColorsPath
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoadFailed: {
            if (root.activeSource === "json") root.activeSource = "fallback"
            if (root.activeSource === "fallback") noctaliaPalette.reload()
        }
        onLoaded: {
            try {
                if (!root.applyNoctaliaPalette(JSON.parse(text()))) {
                    if (root.activeSource === "json") root.activeSource = "fallback"
                    if (root.activeSource === "fallback") noctaliaPalette.reload()
                }
            } catch (error) {
                if (root.activeSource === "json") root.activeSource = "fallback"
                if (root.activeSource === "fallback") noctaliaPalette.reload()
                console.warn("Appearance: invalid Noctalia colors.json", error)
            }
        }
    }

    FileView {
        id: noctaliaPalette
        path: root.noctaliaPalettePath
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoadFailed: {
            if (root.activeSource !== "json") root.applyFallbackPalette()
        }
        onLoaded: {
            if (root.activeSource !== "json" && !root.applyStarshipPalette(text()))
                root.applyFallbackPalette()
        }
    }

    Timer {
        interval: root.activeSource === "starship" ? 30000 : 2000
        repeat: true
        running: root.activeSource !== "json"
        onTriggered: noctaliaColors.reload()
    }

    property QtObject colors: QtObject {
        readonly property color nord0: "#2E3440"
        readonly property color nord1: root.surfaceVariant
        readonly property color nord2: root.surfaceVariant
        readonly property color nord3: root.outline
        readonly property color nord4: root.foreground
        readonly property color nord5: root.foregroundMuted
        readonly property color nord6: root.foreground
        readonly property color nord7: root.secondary
        readonly property color nord8: root.primary
        readonly property color nord9: root.secondary
        readonly property color nord10: root.primary
        readonly property color nord11: root.error
        readonly property color nord12: root.error
        readonly property color nord13: root.secondary
        readonly property color nord14: root.primary
        readonly property color nord15: root.secondary

        readonly property color colLayer0: root.surface
        readonly property color colLayer1: root.surfaceVariant
        readonly property color colText: root.foreground
        readonly property color colTextSub: root.foregroundMuted
        readonly property color colPrimary: root.primary
        readonly property color colOnPrimary: root.primaryForeground
        readonly property color colInversePrimary: root.secondary
        readonly property color colOutlineVariant: root.outline
        readonly property color colShadow: root.shadow
        readonly property color colTextOutline: root.darkMode
            ? "#E0000000"
            : "#E6FFFFFF"
    }
}
