import QtQuick
import QtQuick.Effects
import Quickshell.Io
import "../Common"

Item {
    id: root

    required property var player
    property bool active: false
    LyricsController { id: controller; player: root.player; active: root.active }
    readonly property var lyricsModel: controller.lyricsModel
    readonly property int currentLineIndex: controller.currentLineIndex

    readonly property string trackTitle: player ? (player.trackTitle || "") : ""
    readonly property string trackArtist: player ? (player.trackArtist || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property string trackKey: trackTitle + "\u001f" + trackArtist
    readonly property bool canTogglePlayback: player ? player.canTogglePlaying : false
    readonly property bool canGoPrevious: player ? player.canGoPrevious : false
    readonly property bool canGoNext: player ? player.canGoNext : false

    readonly property string currentLoadedTrackKey: controller.currentLoadedTrackKey
    property bool dragging: false
    readonly property bool contentReady: active
        && player !== null
        && trackTitle !== ""
        && currentLoadedTrackKey === trackKey
        && lyricsModel.length > 0
    readonly property bool hovered: hoverHandler.hovered || dragging
    readonly property rect controlInteractionRect: Qt.rect(
        dragSurface.x,
        controlBar.y,
        dragSurface.width,
        Math.max(controlBar.height, dragSurface.y - controlBar.y)
    )
    readonly property rect dragInteractionRect: Qt.rect(dragSurface.x, dragSurface.y, dragSurface.width, dragSurface.height)
    readonly property rect handleInteractionRect: Qt.rect(
        controlBar.x + controlRow.x + dragHandleArea.x,
        controlBar.y + controlRow.y + dragHandleArea.y,
        dragHandleArea.width,
        dragHandleArea.height
    )

    implicitWidth: 720
    implicitHeight: 136
    opacity: contentReady ? 1 : 0
    visible: opacity > 0.01

    Behavior on opacity {
        NumberAnimation {
            duration: root.contentReady ? 180 : 250
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: root.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    }

    Item {
        anchors.fill: parent
        clip: false

        Rectangle {
            id: controlBar
            anchors {
                top: parent.top
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            width: root.contentReady ? Math.max(0, Math.min(parent.width - 20, 620)) : 0
            height: 42
            radius: 21
            color: Appearance.withAlpha(Appearance.colors.colLayer0, Appearance.darkMode ? 0.90 : 0.94)
            border.width: 1
            border.color: Appearance.withAlpha(Appearance.colors.colOutlineVariant, 0.46)
            opacity: root.hovered && root.player ? 1 : 0
            visible: opacity > 0.01
            layer.enabled: visible
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Appearance.colors.colShadow
                shadowOpacity: Appearance.darkMode ? 0.48 : 0.24
                shadowBlur: 0.72
                shadowVerticalOffset: 2
            }

            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }

            Row {
                id: controlRow
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                spacing: 8

                Item {
                    id: dragHandleArea
                    width: 20
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "⠿"
                        color: Appearance.colors.colPrimary
                        font.family: Sizes.fontFamilyMono
                        font.pixelSize: 16
                        opacity: 0.9
                    }
                }

                Rectangle {
                    id: albumContainer
                    width: 30
                    height: 30
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    color: Appearance.withAlpha(Appearance.colors.colPrimary, 0.26)

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        anchors.margins: 1
                        source: root.artUrl
                        visible: root.artUrl !== ""
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: visible
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    width: coverImage.width
                                    height: coverImage.height
                                    radius: 8
                                    color: "black"
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.artUrl === ""
                        text: "♪"
                        color: Appearance.colors.colPrimary
                        font.family: Sizes.fontFamilyLyrics
                        font.pixelSize: 17
                    }
                }

                Column {
                    width: Math.max(80, controlRow.width
                        - dragHandleArea.width
                        - albumContainer.width
                        - controlButtons.width
                        - controlRow.spacing * 3)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -1

                    Text {
                        width: parent.width
                        text: root.trackTitle
                        textFormat: Text.PlainText
                        color: Appearance.colors.colText
                        font.family: Sizes.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.trackArtist !== "" ? root.trackArtist : "未知艺术家"
                        textFormat: Text.PlainText
                        color: Appearance.colors.colTextSub
                        font.family: Sizes.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        opacity: 0.82
                    }
                }

                Row {
                    id: controlButtons
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        opacity: root.canGoPrevious ? 1 : 0.36
                        scale: previousMouse.pressed ? 0.9 : 1
                        color: previousMouse.containsMouse
                            ? Appearance.withAlpha(Appearance.colors.colLayer1, 0.82)
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 90 } }

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: Appearance.colors.colTextSub
                            font.family: Sizes.fontIcon
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: previousMouse
                            anchors.fill: parent
                            enabled: root.canGoPrevious
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.player.previous()
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        opacity: root.canTogglePlayback ? 1 : 0.36
                        scale: playPauseMouse.pressed ? 0.9 : 1
                        color: playPauseMouse.containsMouse
                            ? Appearance.colors.colPrimary
                            : Appearance.withAlpha(Appearance.colors.colPrimary, 0.24)

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 90 } }

                        Text {
                            anchors.centerIn: parent
                            text: root.player && root.player.isPlaying ? "" : ""
                            color: playPauseMouse.containsMouse
                                ? Appearance.colors.colOnPrimary
                                : Appearance.colors.colPrimary
                            font.family: Sizes.fontIcon
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: playPauseMouse
                            anchors.fill: parent
                            enabled: root.canTogglePlayback
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.player.togglePlaying()
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        opacity: root.canGoNext ? 1 : 0.36
                        scale: nextMouse.pressed ? 0.9 : 1
                        color: nextMouse.containsMouse
                            ? Appearance.withAlpha(Appearance.colors.colLayer1, 0.82)
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 90 } }

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: Appearance.colors.colTextSub
                            font.family: Sizes.fontIcon
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            enabled: root.canGoNext
                            hoverEnabled: true
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.player.next()
                        }
                    }
                }
            }
        }

        Item {
            id: dragSurface
            anchors {
                top: parent.top
                topMargin: 52
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: root.contentReady ? Math.min(parent.width, 640) : 0

            ListView {
                id: lyricsView
                anchors.fill: parent
                clip: true
                interactive: false
                visible: root.lyricsModel.length > 0
                model: root.lyricsModel
                currentIndex: root.currentLineIndex

                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: 0
                highlightMoveDuration: 260
                highlightMoveVelocity: -1

                delegate: Item {
                    required property int index
                    required property var modelData

                    readonly property bool isCurrent: index === lyricsView.currentIndex
                    readonly property bool isNext: index === lyricsView.currentIndex + 1

                    width: ListView.view.width
                    height: 42
                    opacity: isCurrent ? 1 : (isNext ? 0.80 : 0)
                    scale: isCurrent ? 1 : 0.94
                    visible: opacity > 0.01

                    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 40
                        text: modelData.text
                        textFormat: Text.PlainText
                        color: isCurrent ? Appearance.colors.colText : Appearance.colors.colTextSub
                        style: Text.Outline
                        styleColor: Appearance.colors.colTextOutline
                        font.family: Sizes.fontFamilyLyrics
                        font.pixelSize: isCurrent ? 28 : 18
                        font.weight: isCurrent ? Font.DemiBold : Font.Medium
                        font.letterSpacing: isCurrent ? 0.2 : 0
                        font.hintingPreference: Font.PreferVerticalHinting
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                }
            }
        }
    }
}
