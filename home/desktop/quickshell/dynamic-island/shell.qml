import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import "./Content"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: overlayWindow

        required property var modelData
        screen: modelData

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

        function clampSurfacePosition() {
            var maximumX = Math.max(edgeMargin, width - lyricSurface.width - edgeMargin)
            var maximumY = Math.max(edgeMargin, height - lyricSurface.height - edgeMargin)
            lyricSurface.x = Math.max(edgeMargin, Math.min(lyricSurface.x, maximumX))
            lyricSurface.y = Math.max(edgeMargin, Math.min(lyricSurface.y, maximumY))
        }

        function restoreSurfacePosition() {
            var availableWidth = Math.max(0, width - lyricSurface.width - edgeMargin * 2)
            var availableHeight = Math.max(0, height - lyricSurface.height - edgeMargin * 2)
            lyricSurface.x = edgeMargin + availableWidth * Math.max(0, Math.min(position.xRatio, 1))
            lyricSurface.y = edgeMargin + availableHeight * Math.max(0, Math.min(position.yRatio, 1))
            clampSurfacePosition()
        }

        function saveSurfacePosition() {
            var availableWidth = Math.max(1, width - lyricSurface.width - edgeMargin * 2)
            var availableHeight = Math.max(1, height - lyricSurface.height - edgeMargin * 2)
            position.xRatio = Math.max(0, Math.min((lyricSurface.x - edgeMargin) / availableWidth, 1))
            position.yRatio = Math.max(0, Math.min((lyricSurface.y - edgeMargin) / availableHeight, 1))
            positionFile.writeAdapter()
        }

        onWidthChanged: {
            if (!lyricsDrag.active && !handleDrag.active) Qt.callLater(restoreSurfacePosition)
        }
        onHeightChanged: {
            if (!lyricsDrag.active && !handleDrag.active) Qt.callLater(restoreSurfacePosition)
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
            onLoaded: Qt.callLater(overlayWindow.restoreSurfacePosition)
            onLoadFailed: Qt.callLater(overlayWindow.restoreSurfacePosition)

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
            running: true
            onTriggered: overlayWindow.refreshPlayers()
        }

        LyricsContent {
            id: lyricSurface

            x: Math.max(overlayWindow.edgeMargin, (overlayWindow.width - width) / 2)
            y: Math.max(overlayWindow.edgeMargin, overlayWindow.height * 0.16)
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
                target: lyricSurface
                acceptedButtons: Qt.LeftButton
                xAxis.minimum: overlayWindow.edgeMargin
                xAxis.maximum: Math.max(overlayWindow.edgeMargin, overlayWindow.width - lyricSurface.width - overlayWindow.edgeMargin)
                yAxis.minimum: overlayWindow.edgeMargin
                yAxis.maximum: Math.max(overlayWindow.edgeMargin, overlayWindow.height - lyricSurface.height - overlayWindow.edgeMargin)
                onActiveChanged: {
                    lyricSurface.dragging = active || handleDrag.active
                    if (!lyricSurface.dragging) overlayWindow.saveSurfacePosition()
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
                target: lyricSurface
                acceptedButtons: Qt.LeftButton
                xAxis.minimum: overlayWindow.edgeMargin
                xAxis.maximum: Math.max(overlayWindow.edgeMargin, overlayWindow.width - lyricSurface.width - overlayWindow.edgeMargin)
                yAxis.minimum: overlayWindow.edgeMargin
                yAxis.maximum: Math.max(overlayWindow.edgeMargin, overlayWindow.height - lyricSurface.height - overlayWindow.edgeMargin)
                onActiveChanged: {
                    lyricSurface.dragging = active || lyricsDrag.active
                    if (!lyricSurface.dragging) overlayWindow.saveSurfacePosition()
                }
            }
        }

        Component.onCompleted: Qt.callLater(restoreSurfacePosition)
    }
}
