import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../Common"

Item {
    id: root

    required property var player
    property bool active: false
    property var lyricsModel: []
    property int currentLineIndex: 0

    readonly property string trackTitle: player ? (player.trackTitle || "") : ""
    readonly property string trackArtist: player ? (player.trackArtist || "") : ""
    readonly property string playerName: player ? (player.identity || player.dbusName || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""

    property string currentLoadedTitle: ""
    property bool fetchValid: false

    property int lyricsTextWidth: 350
    implicitWidth: 120 + lyricsTextWidth
    implicitHeight: 32

    Process {
        id: lyricsFetcher
        command: ["python3", Paths.scriptPath("lyrics_fetcher.py"), root.trackTitle, root.trackArtist, root.playerName, "/tmp/qs_lyrics_cache"]
        stdout: SplitParser {
            onRead: data => {
                if (!root.fetchValid) return
                root.fetchValid = false
                fetchTimeout.stop()
                try {
                    var json = JSON.parse(data)
                    if (json.length > 0) {
                        root.lyricsModel = json; root.currentLineIndex = 0;
                        root.currentLoadedTitle = root.trackTitle
                    } else {
                        root.lyricsModel = [{time: 0, text: "暂无歌词"}]
                    }
                } catch (e) { root.lyricsModel = [{time: 0, text: "歌词错误"}] }
            }
        }
        onExited: fetchTimeout.stop()
        onRunningChanged: { if (!running) fetchTimeout.stop() }
    }

    Timer {
        id: fetchTimeout
        interval: 10000; repeat: false
        onTriggered: {
            root.fetchValid = false
            if (lyricsFetcher.running) {
                lyricsFetcher.running = false
                root.lyricsModel = [{time: 0, text: "歌词获取超时"}]
            }
        }
    }

    onTrackTitleChanged: {
        root.fetchValid = false
        if (lyricsFetcher.running) { lyricsFetcher.running = false; fetchTimeout.stop() }
        root._posBase = 0; root._posRefTime = 0; root._posSyncCounter = 0
        triggerReload()
    }
    onActiveChanged: {
        if (active && root.trackTitle !== root.currentLoadedTitle) triggerReload()
        if (active && root.player) { root._refreshFromPlayer() }
        else { root._posRefTime = 0 }
    }

    function triggerReload() {
        if (!root.active) return
        root.fetchValid = false
        if (lyricsFetcher.running) {
            lyricsFetcher.running = false
            fetchTimeout.stop()
        }
        debounceTimer.restart()
    }

    Timer {
        id: debounceTimer; interval: 300; repeat: false;
        onTriggered: {
            if (root.trackTitle !== "") {
                root.lyricsModel = []; root.currentLineIndex = 0;
                root.lyricsTextWidth = 350;
                root.fetchValid = true
                lyricsFetcher.running = true
                fetchTimeout.restart()
            }
        }
    }

    property double _posBase: 0
    property double _posRefTime: 0
    property int _posSyncCounter: 0

    function _currentSec() {
        if (_posRefTime === 0) return 0
        return _posBase + (Date.now() - _posRefTime) / 1000
    }

    function _refreshFromPlayer() {
        if (!root.player) return
        var raw = root.player.position
        if (isNaN(raw) || raw < 0) return
        var sec = (raw > 100000) ? (raw / 1000000) : raw
        _posBase = sec
        _posRefTime = Date.now()
        _posSyncCounter = 0
    }

    Timer {
        id: syncTimer
        interval: 100
        running: root.active && root.lyricsModel.length > 1 && root.player
        repeat: true
        onTriggered: {
            if (!root.player) return
            root._posSyncCounter++
            if (root._posSyncCounter >= 10) root._refreshFromPlayer()
            var currentSec = root._currentSec()
            // Fast seek detection: if player position jumped, sync immediately
            var raw = root.player.position
            if (!isNaN(raw) && raw >= 0) {
                var playerSec = (raw > 100000) ? (raw / 1000000) : raw
                if (Math.abs(playerSec - currentSec) > 2.0) root._refreshFromPlayer()
            }
            var activeIdx = -1
            for (var i = 0; i < root.lyricsModel.length; i++) {
                if (root.lyricsModel[i].time <= (currentSec + 0.5)) activeIdx = i; else break
            }
            if (activeIdx === -1) activeIdx = 0
            if (activeIdx !== root.currentLineIndex) {
                root.currentLineIndex = activeIdx
            }
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        Text {
            visible: root.lyricsModel.length === 0 && root.active && root.trackTitle !== ""
            anchors.centerIn: parent
            text: "加载歌词中…"
            color: Appearance.colors.colTextSub
            font.family: Sizes.fontFamily
            font.pixelSize: 13
        }

        Row {
            id: leftSection
            anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Item {
                id: albumCoverContainer
                anchors.verticalCenter: parent.verticalCenter
                width: 26; height: 26

                Image {
                    id: coverImg; anchors.fill: parent
                    source: root.artUrl; visible: root.artUrl !== ""; fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: ShaderEffectSource { sourceItem: Rectangle { width: coverImg.width; height: coverImg.height; radius: 5; color: "black" } }
                    }
                }
                Text {
                    visible: root.artUrl === ""; anchors.centerIn: parent
                    text: ""; font.family: Sizes.fontIcon; font.pixelSize: 14; color: Appearance.colors.colTextSub
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player) root.player.playPause() }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                font.family: Sizes.fontIcon
                font.pixelSize: 12
                color: Appearance.colors.colTextSub
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player) root.player.next() }
                }
            }
        }

        ListView {
            id: lyricsView
            anchors.left: leftSection.right
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: root.lyricsTextWidth

            interactive: false
            model: root.lyricsModel
            currentIndex: root.currentLineIndex

            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: 0
            highlightMoveDuration: 400

            delegate: Item {
                width: ListView.view.width
                height: 32
                property bool isCurrent: ListView.isCurrentItem

                onIsCurrentChanged: {
                    if (isCurrent) {
                        root.lyricsTextWidth = Math.max(root.lyricsTextWidth, Math.min(lyricText.implicitWidth, 800))
                    }
                }

                Text {
                    id: lyricText
                    anchors.centerIn: parent
                    text: modelData.text
                    color: Appearance.colors.colText
                    font.family: Sizes.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
