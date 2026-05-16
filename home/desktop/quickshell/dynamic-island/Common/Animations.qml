pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject curves
    property QtObject durations
    property QtObject animation

    curves: QtObject {
        readonly property var emphasized: [0.05, 0, 0.1333, 0.06, 0.1667, 0.4, 0.2083, 0.82, 0.25, 1, 1, 1]
        readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property var standard: [0.2, 0, 0, 1, 1, 1]
        readonly property var standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property var standardDecel: [0, 0, 0, 1, 1, 1]
    }

    durations: QtObject {
        readonly property int small: 200
        readonly property int normal: 400
        readonly property int large: 600
        readonly property int extraLarge: 1000
    }

    animation: QtObject {
        readonly property QtObject standardSmall: QtObject {
            readonly property int duration: root.durations.small
            readonly property int type: Easing.BezierSpline
            readonly property var bezierCurve: root.curves.standard
        }
        readonly property QtObject standard: QtObject {
            readonly property int duration: root.durations.normal
            readonly property int type: Easing.BezierSpline
            readonly property var bezierCurve: root.curves.standard
        }
    }
}
