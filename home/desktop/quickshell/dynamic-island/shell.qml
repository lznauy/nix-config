import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell.Wayland
import "./Common"
import "./Content"

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: islandWindow
        required property var modelData
        screen: modelData

        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: 80
        margins { bottom: 0 }

        color: "transparent"
        exclusiveZone: -1
        WlrLayershell.namespace: "qs-dynamic-island"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.focusable: root.isLyricsMode

        Item {
            id: hitBoxRegion
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.isCollapsedMode ? 400 : root.width
            height: root.isCollapsedMode ? 32 : root.height
        }
        mask: Region { item: hitBoxRegion }

        Item {
            id: maskContainer
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.width
            height: root.height

            ClippingRectangle {
                id: root
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                bottomLeftRadius: 0
                bottomRightRadius: 0
                color: Appearance.colors.colLayer0

                property real animRadius: targetR
                radius: animRadius

                property bool showLyrics: false
                property bool isLyricsMode: showLyrics

                Timer {
                    id: lyricsHideDebounce
                    interval: 150; repeat: false
                    onTriggered: root.showLyrics = false
                }
                property bool isCollapsedMode: !isLyricsMode
                property bool isCollapsedHovered: isCollapsedMode && islandMouseArea.containsMouse

                property int lyricsW: lyricsWidget.implicitWidth
                property int lyricsH: lyricsWidget.implicitHeight
                property int collapsedW: 200
                property int collapsedH: 4

                property int targetR: isLyricsMode ? 24 : (isCollapsedHovered ? 18 : 4)
                property int targetW: isLyricsMode ? lyricsW : collapsedW
                property int targetH: isLyricsMode ? lyricsH : (isCollapsedHovered ? 32 : collapsedH)

                property real wDamping: DynamicIslandMotion.initialDamping
                property real hDamping: DynamicIslandMotion.initialDamping
                property real rDamping: DynamicIslandMotion.initialDamping

                width: targetW
                height: targetH

                onTargetWChanged: { wDamping = (targetW > width) ? DynamicIslandMotion.expandingDamping : DynamicIslandMotion.shrinkingDamping }
                onTargetHChanged: { hDamping = (targetH > height) ? DynamicIslandMotion.expandingDamping : DynamicIslandMotion.shrinkingDamping }
                onTargetRChanged: { rDamping = (targetR > animRadius) ? DynamicIslandMotion.expandingDamping : DynamicIslandMotion.shrinkingDamping }

                Behavior on width { SpringAnimation { spring: DynamicIslandMotion.spring; mass: DynamicIslandMotion.mass; damping: root.wDamping; epsilon: DynamicIslandMotion.epsilon } }
                Behavior on height { SpringAnimation { spring: DynamicIslandMotion.spring; mass: DynamicIslandMotion.mass; damping: root.hDamping; epsilon: DynamicIslandMotion.epsilon } }
                Behavior on animRadius { SpringAnimation { spring: DynamicIslandMotion.spring; mass: DynamicIslandMotion.mass; damping: root.rDamping; epsilon: DynamicIslandMotion.epsilon } }

                focus: isLyricsMode
                Keys.onEscapePressed: (event) => { root.showLyrics = false; lyricsHideDebounce.stop(); root.autoDismissed = true; event.accepted = true }

                property var currentPlayer: null
                property bool autoDismissed: false
                property string lastTrackId: ""
                property bool lyricsPeek: false

                onCurrentPlayerChanged: {
                    if (currentPlayer) {
                        currentPlayer.isPlayingChanged.connect(onPlayerIsPlayingChanged)
                        currentPlayer.trackChanged.connect(onPlayerTrackChanged)
                    }
                }

                function onPlayerIsPlayingChanged() {
                    if (root.currentPlayer && root.currentPlayer.isPlaying) {
                        lyricsHideDebounce.stop()
                        if (!root.autoDismissed) root.showLyrics = true
                    } else if (root.currentPlayer && !root.currentPlayer.isPlaying) {
                        lyricsHideDebounce.restart()
                    }
                }

                function onPlayerTrackChanged() {
                    root.onActivePlayerTrackChanged()
                }

                Timer {
                    id: lyricsPeekTimer
                    interval: 600; repeat: false
                    onTriggered: {
                        if (root.isLyricsMode && islandMouseArea.containsMouse)
                            root.lyricsPeek = true
                    }
                }

                Timer {
                    id: playerPollTimer
                    interval: root.currentPlayer ? 15000 : 2000
                    repeat: true; triggeredOnStart: true
                    running: true
                    onTriggered: root.refreshPlayers()
                }

                function onActivePlayerTrackChanged() {
                    if (!root.currentPlayer || !root.currentPlayer.isPlaying) return
                    var trackId = root.currentPlayer.dbusName + root.currentPlayer.trackTitle
                    if (trackId !== root.lastTrackId) {
                        root.lastTrackId = trackId
                        root.autoDismissed = false
                    }
                    if (!root.autoDismissed) root.showLyrics = true
                }

                function refreshPlayers() {
                    var players = Mpris.players.values
                    if (!players || players.length === 0) {
                        root.currentPlayer = null
                        lyricsHideDebounce.restart()
                        return
                    }

                    var playingPlayer = null
                    for (var i = 0; i < players.length; i++) {
                        if (players[i].isPlaying) { playingPlayer = players[i]; break }
                    }

                    if (playingPlayer) {
                        var trackId = playingPlayer.dbusName + playingPlayer.trackTitle
                        if (trackId !== root.lastTrackId) {
                            root.lastTrackId = trackId
                            root.autoDismissed = false
                        }
                        if (root.currentPlayer !== playingPlayer) root.currentPlayer = playingPlayer
                        if (!root.autoDismissed) {
                            lyricsHideDebounce.stop()
                            root.showLyrics = true
                        }
                    } else {
                        lyricsHideDebounce.restart()
                        if (root.currentPlayer) {
                            var currentIsValid = false
                            for (var j = 0; j < players.length; j++) {
                                if (players[j] === root.currentPlayer) { currentIsValid = true; break }
                            }
                            if (!currentIsValid) root.currentPlayer = players[0]
                        }
                    }
                }

                ClockContent {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.collapsedW
                    height: 32
                    opacity: (root.isCollapsedMode && root.isCollapsedHovered) || root.lyricsPeek ? 1 : 0
                    visible: opacity > 0.01
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                LyricsContent {
                    id: lyricsWidget
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.lyricsW
                    height: root.lyricsH
                    player: root.currentPlayer
                    active: root.isLyricsMode && root.currentPlayer !== null
                    opacity: root.isLyricsMode && !root.lyricsPeek ? 1 : 0
                    visible: opacity > 0.01
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

                MouseArea {
                    id: islandMouseArea
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: root.isCollapsedMode ? 32 : parent.height
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: (mouse) => {
                        if (root.isLyricsMode) {
                            root.autoDismissed = true
                            lyricsHideDebounce.restart()
                        } else {
                            root.autoDismissed = false
                            lyricsHideDebounce.stop()
                            root.showLyrics = true
                        }
                    }
                    onEntered: { if (root.isLyricsMode) { root.lyricsPeek = false; lyricsPeekTimer.restart() } }
                    onExited: {
                        root.lyricsPeek = false
                        lyricsPeekTimer.stop()
                    }
                    onPositionChanged: {
                        if (root.isLyricsMode) {
                            root.lyricsPeek = false
                            lyricsPeekTimer.restart()
                        }
                    }
                }
            }
        }
    }
}
