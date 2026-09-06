import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import "./Content"

Scope {
    id: root

    property bool islandVisible: true

    IpcHandler {
        target: "island"

        function toggle(): void {
            root.islandVisible = !root.islandVisible
        }

        function show(): void {
            root.islandVisible = true
        }

        function hide(): void {
            root.islandVisible = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlayWindow

            required property var modelData
            screen: modelData
            visible: root.islandVisible

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            exclusiveZone: -1
            WlrLayershell.namespace: "qs-dynamic-island"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.focusable: false

            readonly property int edgeMargin: 24
            // 歌词悬浮层的可活动范围，位置比例 (position.xRatio/yRatio) 是唯一数据源
            readonly property real freeWidth: Math.max(0, width - lyricSurface.width - edgeMargin * 2)
            readonly property real freeHeight: Math.max(0, height - lyricSurface.height - edgeMargin * 2)
            readonly property string stateHome: {
                var configured = Quickshell.env("XDG_STATE_HOME")
                return configured !== "" ? configured : Quickshell.env("HOME") + "/.local/state"
            }
            readonly property string screenKey: modelData.name.replace(/[^a-zA-Z0-9_.-]/g, "_")
            readonly property string positionPath: stateHome + "/quickshell/dynamic-island/position-" + screenKey + ".json"

            property var currentPlayer: null
            readonly property var allowedPlayers: ["splayer"]

            function isPlayerAllowed(player) {
                if (!player) return false
                if (allowedPlayers.length === 0) return true

                var identity = ((player.identity || "") + " " + (player.dbusName || "")).toLowerCase()
                for (var index = 0; index < allowedPlayers.length; index++) {
                    if (identity.indexOf(allowedPlayers[index].toLowerCase()) !== -1) return true
                }
                return false
            }

            function refreshPlayers() {
                var players = Mpris.players.values
                if (!players || players.length === 0) {
                    currentPlayer = null
                    return
                }

                var playingPlayer = null
                var currentAllowedPlayer = null
                var firstAllowedPlayer = null
                for (var index = 0; index < players.length; index++) {
                    var player = players[index]
                    if (!isPlayerAllowed(player)) continue
                    if (!firstAllowedPlayer) firstAllowedPlayer = player
                    if (player === currentPlayer) currentAllowedPlayer = player
                    if (player.isPlaying) {
                        playingPlayer = player
                        break
                    }
                }

                currentPlayer = playingPlayer || currentAllowedPlayer || firstAllowedPlayer
            }

            function clampX(x) {
                return Math.max(edgeMargin, Math.min(x, Math.max(edgeMargin, width - lyricSurface.width - edgeMargin)))
            }

            function clampY(y) {
                return Math.max(edgeMargin, Math.min(y, Math.max(edgeMargin, height - lyricSurface.height - edgeMargin)))
            }

            // 拖拽时把像素坐标转换为比例写入 position，位置由绑定自动跟随
            function setSurfacePosition(px, py) {
                var clampedX = clampX(px)
                var clampedY = clampY(py)
                position.xRatio = (clampedX - edgeMargin) / Math.max(1, freeWidth)
                position.yRatio = (clampedY - edgeMargin) / Math.max(1, freeHeight)
            }

            mask: Region {
                Region { item: controlInputRegion }
                Region { item: lyricDragRegion }
            }

            FileView {
                id: positionFile
                path: overlayWindow.positionPath
                printErrors: false
                atomicWrites: true

                JsonAdapter {
                    id: position
                    property real xRatio: 0.5
                    property real yRatio: 0.16
                }
            }

            Timer {
                interval: overlayWindow.currentPlayer && overlayWindow.currentPlayer.isPlaying ? 15000 : 2000
                repeat: true
                triggeredOnStart: true
                running: overlayWindow.visible
                onTriggered: overlayWindow.refreshPlayers()
            }

            LyricsContent {
                id: lyricSurface

                x: overlayWindow.edgeMargin + overlayWindow.freeWidth * position.xRatio
                y: overlayWindow.edgeMargin + overlayWindow.freeHeight * position.yRatio
                width: Math.min(implicitWidth, overlayWindow.width - overlayWindow.edgeMargin * 2)
                height: implicitHeight
                player: overlayWindow.currentPlayer
                active: overlayWindow.currentPlayer !== null
            }

            Item {
                id: controlInputRegion
                x: lyricSurface.x + lyricSurface.controlInteractionRect.x
                y: lyricSurface.y + lyricSurface.controlInteractionRect.y
                width: lyricSurface.contentReady && lyricSurface.hovered
                    ? lyricSurface.controlInteractionRect.width : 0
                height: lyricSurface.contentReady ? lyricSurface.controlInteractionRect.height : 0
            }

            Item {
                id: lyricDragRegion
                x: lyricSurface.x + lyricSurface.dragInteractionRect.x
                y: lyricSurface.y + lyricSurface.dragInteractionRect.y
                width: lyricSurface.contentReady ? lyricSurface.dragInteractionRect.width : 0
                height: lyricSurface.contentReady ? lyricSurface.dragInteractionRect.height : 0

                DragHandler {
                    id: lyricsDrag
                    acceptedButtons: Qt.LeftButton
                    property point startPoint
                    onActiveChanged: {
                        if (active) startPoint = Qt.point(lyricSurface.x, lyricSurface.y)
                        lyricSurface.dragging = active || handleDrag.active
                        if (!lyricSurface.dragging) positionFile.writeAdapter()
                    }
                    onTranslationChanged: {
                        if (active) overlayWindow.setSurfacePosition(startPoint.x + translation.x, startPoint.y + translation.y)
                    }
                }
            }

            Item {
                id: handleDragRegion
                x: lyricSurface.x + lyricSurface.handleInteractionRect.x
                y: lyricSurface.y + lyricSurface.handleInteractionRect.y
                width: lyricSurface.handleInteractionRect.width
                height: lyricSurface.handleInteractionRect.height

                DragHandler {
                    id: handleDrag
                    acceptedButtons: Qt.LeftButton
                    property point startPoint
                    onActiveChanged: {
                        if (active) startPoint = Qt.point(lyricSurface.x, lyricSurface.y)
                        lyricSurface.dragging = active || lyricsDrag.active
                        if (!lyricSurface.dragging) positionFile.writeAdapter()
                    }
                    onTranslationChanged: {
                        if (active) overlayWindow.setSurfacePosition(startPoint.x + translation.x, startPoint.y + translation.y)
                    }
                }
            }
        }
    }
}
