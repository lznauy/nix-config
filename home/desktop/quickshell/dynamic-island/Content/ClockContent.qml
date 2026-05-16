import QtQuick
import "../Common"

Item {
    id: root

    property string dateStr: ""

    property int h0: 0
    property int h1: 0
    property int m0: 0
    property int m1: 0

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let d = new Date()
            root.dateStr = d.toLocaleString(Qt.locale("en_US"), "ddd dd MMM")
            let hStr = d.getHours().toString().padStart(2, '0')
            let mStr = d.getMinutes().toString().padStart(2, '0')

            root.h0 = parseInt(hStr[0])
            root.h1 = parseInt(hStr[1])
            root.m0 = parseInt(mStr[0])
            root.m1 = parseInt(mStr[1])
        }
    }

    component RollingDigit : Item {
        id: digitContainer
        property int targetDigit: 0
        property color digitColor: "white"
        property real digitRotation: 0
        property real digitOffset: 0

        width: digitText.implicitWidth
        height: 14
        clip: true

        rotation: digitRotation
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: digitOffset

        property real animatedY: -targetDigit * 14
        property int _prevDigit: targetDigit

        onTargetDigitChanged: {
            scrollAnim.stop()
            wrapAnim.stop()
            snapTimer.stop()

            let currentY = animatedY
            let newY = -targetDigit * 14

            if (_prevDigit === 9 && targetDigit === 0) {
                wrapAnim.from = currentY
                wrapAnim.to = -140
                wrapAnim.start()
                snapTimer.restart()
            } else {
                scrollAnim.from = currentY
                scrollAnim.to = newY
                scrollAnim.start()
            }

            _prevDigit = targetDigit
        }

        SpringAnimation {
            id: scrollAnim
            target: digitContainer; property: "animatedY"
            spring: 3.5; damping: 0.75; mass: 1.0
        }

        SpringAnimation {
            id: wrapAnim
            target: digitContainer; property: "animatedY"
            spring: 8.0; damping: 0.9; mass: 0.3
        }

        Timer {
            id: snapTimer; interval: 200; repeat: false
            onTriggered: {
                wrapAnim.stop()
                digitContainer.animatedY = 0
            }
        }

        Text {
            id: digitText
            text: "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n0"
            color: digitContainer.digitColor
            font.family: Sizes.fontFamilyMono
            font.pixelSize: 12
            font.weight: Font.DemiBold
            lineHeight: 14
            lineHeightMode: Text.FixedHeight

            y: digitContainer.animatedY
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: root.dateStr
            color: Appearance.colors.colPrimary
            font.family: Sizes.fontFamily
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "|"
            color: Appearance.colors.colOutlineVariant
            font.family: Sizes.fontFamily
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            Row {
                spacing: -1

                RollingDigit {
                    targetDigit: root.h0
                    digitColor: Appearance.colors.colInversePrimary
                    digitRotation: -3
                    digitOffset: -2
                }
                RollingDigit {
                    targetDigit: root.h1
                    digitColor: Appearance.colors.colPrimary
                    digitRotation: 3
                    digitOffset: 1
                }
            }

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1

                Rectangle { width: 3; height: 3; radius: 1; color: Appearance.colors.colOutlineVariant }
                Rectangle { width: 3; height: 3; radius: 1; color: Appearance.colors.colOutlineVariant }
            }

            Row {
                spacing: 1

                RollingDigit {
                    targetDigit: root.m0
                    digitColor: Appearance.colors.colInversePrimary
                    digitRotation: -2
                    digitOffset: -1
                }
                RollingDigit {
                    targetDigit: root.m1
                    digitColor: Appearance.colors.colPrimary
                    digitRotation: 2
                    digitOffset: 1
                }
            }
        }
    }
}
