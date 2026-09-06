import QtQuick
import Quickshell.Io

Item {
    id: root
    required property var player
    property bool active: false
    property var lyricsModel: []
    property int currentLineIndex: 0

    readonly property string trackTitle: player ? (player.trackTitle || "") : ""
    readonly property string trackArtist: player ? (player.trackArtist || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property string trackKey: trackTitle + "\u001f" + trackArtist
    readonly property bool canTogglePlayback: player ? player.canTogglePlaying : false
    readonly property bool canGoPrevious: player ? player.canGoPrevious : false
    readonly property bool canGoNext: player ? player.canGoNext : false

    property string currentLoadedTrackKey: ""
    property string requestedTrackKey: ""
    property string requestedTitle: ""
    property string requestedArtist: ""
    property bool fetchValid: false
    function _hasRenderableLyrics(lines) {
        if (!Array.isArray(lines) || lines.length === 0) return false
        for (var index = 0; index < lines.length; index++) {
            var text = lines[index] && lines[index].text ? String(lines[index].text).trim() : ""
            if (text !== ""
                    && text !== "暂无歌词"
                    && text !== "歌词错误"
                    && text !== "歌词获取超时") return true
        }
        return false
    }

    Process {
        id: lyricsFetcher
        command: ["qs-lyrics", root.requestedTitle, root.requestedArtist]
        stdout: SplitParser {
            onRead: data => {
                if (!root.fetchValid || root.requestedTrackKey !== root.trackKey) return
                root.fetchValid = false
                fetchTimeout.stop()
                try {
                    var json = JSON.parse(data)
                    if (root._hasRenderableLyrics(json)) {
                        root.lyricsModel = json; root.currentLineIndex = 0;
                        root.currentLoadedTrackKey = root.requestedTrackKey
                    } else {
                        root.lyricsModel = []
                        root.currentLoadedTrackKey = root.requestedTrackKey
                    }
                } catch (e) {
                    root.lyricsModel = []
                    root.currentLoadedTrackKey = root.requestedTrackKey
                }
            }
        }
        onExited: function() {
            fetchTimeout.stop()
            if (root.fetchValid) {
                root.fetchValid = false
                root.lyricsModel = []
                root.currentLoadedTrackKey = root.requestedTrackKey
            }
        }
        onRunningChanged: { if (!running) fetchTimeout.stop() }
    }

    Timer {
        id: fetchTimeout
        interval: 10000; repeat: false
        onTriggered: {
            root.fetchValid = false
            if (lyricsFetcher.running) {
                lyricsFetcher.running = false
                root.lyricsModel = []
                root.currentLoadedTrackKey = root.requestedTrackKey
            }
        }
    }

    onTrackKeyChanged: {
        root.fetchValid = false
        if (lyricsFetcher.running) { lyricsFetcher.running = false; fetchTimeout.stop() }
        debounceTimer.stop()
        root._posBase = 0; root._posRefTime = 0; root._posSyncCounter = 0
        if (root.trackTitle === "") {
            root.lyricsModel = []
            root.currentLineIndex = 0
            root.currentLoadedTrackKey = ""
            return
        }
        triggerReload()
    }
    onActiveChanged: {
        if (active && root.trackKey !== root.currentLoadedTrackKey) triggerReload()
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
            if (root.active && root.trackTitle !== "") {
                root.lyricsModel = []; root.currentLineIndex = 0;
                root.requestedTrackKey = root.trackKey
                root.requestedTitle = root.trackTitle
                root.requestedArtist = root.trackArtist
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

    function _lineIndexAt(currentSec) {
        var targetTime = currentSec + 0.5
        var low = 0
        var high = root.lyricsModel.length - 1
        var activeIndex = 0

        while (low <= high) {
            var middle = Math.floor((low + high) / 2)
            if (root.lyricsModel[middle].time <= targetTime) {
                activeIndex = middle
                low = middle + 1
            } else {
                high = middle - 1
            }
        }

        return activeIndex
    }

    Timer {
        id: syncTimer
        interval: 100
        running: root.active && root.lyricsModel.length > 1 && root.player && root.player.isPlaying
        repeat: true
        onRunningChanged: {
            if (running) root._refreshFromPlayer()
        }
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
            var activeIdx = root._lineIndexAt(currentSec)
            if (activeIdx !== root.currentLineIndex) {
                root.currentLineIndex = activeIdx
            }
        }
    }

}
