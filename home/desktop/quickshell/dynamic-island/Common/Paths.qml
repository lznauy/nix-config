pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string shellDir: Quickshell.shellDir
    readonly property string scriptsDir: shellDir + "/scripts"

    function scriptPath(name) {
        return scriptsDir + "/" + name;
    }
}
