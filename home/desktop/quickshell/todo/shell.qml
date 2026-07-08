import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "./Theme.js" as Theme
import "./ScreenModel.js" as ScreenModel

ShellRoot {
    id: root

    property real panelOpacity: 0
    property real panelScale: 0.95
    property real panelY: 15

    property string dataDir: Quickshell.env("HOME") + "/.local/share/quickshell"
    property string dataFile: dataDir + "/todos.json"
    property var todos: []

    Component.onCompleted: {
        ensureDirProcess.running = true
        loadTimer.start()
        enterAnimation.start()
    }

    Process {
        id: ensureDirProcess
        command: ["mkdir", "-p", root.dataDir]
    }

    // ── Animations ──────────────────────────────────────────

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation { target: root; property: "panelOpacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "panelScale"; from: 0.95; to: 1.0; duration: 280; easing.type: Easing.OutBack; easing.overshoot: 0.8 }
        NumberAnimation { target: root; property: "panelY"; from: 15; to: 0; duration: 200; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: exitAnimation
        NumberAnimation { target: root; property: "panelOpacity"; to: 0; duration: 120; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "panelScale"; to: 0.95; duration: 120; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "panelY"; to: -10; duration: 120; easing.type: Easing.InCubic }
        onFinished: {
            if (writeTmpProcess.running || saveQueued || saveTimer.running) { quitWaitTimer.start() }
            else { Qt.quit() }
        }
    }

    Timer {
        id: quitWaitTimer
        interval: 30
        repeat: true
        property int elapsed: 0
        onTriggered: {
            elapsed += 30
            if (!writeTmpProcess.running && (root.saveQueued || saveTimer.running)) {
                root.flushSave()
            }
            if ((!writeTmpProcess.running && !root.saveQueued && !saveTimer.running) || elapsed >= 3000) {
                stop()
                Qt.quit()
            }
        }
    }

    // ── Data persistence ────────────────────────────────────

    FileView { id: fileView; path: root.dataFile }

    Timer {
        id: loadTimer
        interval: 100
        repeat: false
        onTriggered: root.loadData()
    }

    function loadData() {
        var raw = fileView.text()
        if (raw && raw.length > 0) {
            try {
                var data = JSON.parse(raw)
                todos = data.todos || data || []
            } catch (e) {
                todos = []
            }
        }
    }

    // Debounced save: accumulates rapid changes, writes once after
    // `delay` ms of inactivity. Uses a temp file + rename for atomicity.
    property int saveDelay: 300
    property string tmpFile: root.dataFile + ".tmp"
    property bool saveQueued: false

    Timer {
        id: saveTimer
        interval: root.saveDelay
        repeat: false
        onTriggered: root.flushSave()
    }

    function saveData() {
        saveQueued = true
        saveTimer.restart()
    }

    function flushSave() {
        saveTimer.stop()
        if (writeTmpProcess.running) {
            return
        }
        if (!saveQueued) return
        var json = JSON.stringify({todos: root.todos}, null, 2)
        writeTmpProcess.writeCmd = json
        saveQueued = false
        writeTmpProcess.stdinEnabled = true
        writeTmpProcess.running = true
    }

    Process {
        id: writeTmpProcess
        property string writeCmd: ""
        command: ["sh", "-c", "mkdir -p \"$1\" && cat > \"$2\" && mv \"$2\" \"$3\"", "qs-todo-save", root.dataDir, root.tmpFile, root.dataFile]
        stdinEnabled: true
        onStarted: {
            writeTmpProcess.write(writeCmd)
            writeTmpProcess.stdinEnabled = false
        }
        onExited: {
            var code = writeTmpProcess.exitCode
            if (code !== 0) {
                saveQueued = true
                console.warn("[todo] save failed (exit " + code + ")")
            } else if (saveQueued || saveTimer.running) {
                root.flushSave()
            }
        }
    }

    function closeWithAnimation() {
        flushSave()
        exitAnimation.start()
    }

    function handleGlobalKeys(event) {
        if (event.key === Qt.Key_Escape) { closeWithAnimation() }
    }

    // ── Todo operations ─────────────────────────────────────

    function addTodo(text) {
        if (text.trim() === "") return
        todos = todos.concat([{
            id: Date.now(),
            text: text.trim(),
            done: false,
            createdAt: new Date().toISOString()
        }])
        saveData()
    }

    function toggleTodo(id) {
        todos = todos.map(function(t) {
            return t.id === id ? {id: t.id, text: t.text, done: !t.done, createdAt: t.createdAt} : t
        })
        saveData()
    }

    function deleteTodo(id) {
        todos = todos.filter(function(t) { return t.id !== id })
        saveData()
    }

    function clearCompleted() {
        todos = todos.filter(function(t) { return !t.done })
        saveData()
    }

    // ── Background overlay ──────────────────────────────────

    Variants {
        model: ScreenModel.targetScreens(Quickshell.screens, Quickshell.env("QS_TARGET_OUTPUT"))

        PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            color: Theme.alpha("#000000", 0.25 * root.panelOpacity)
            WlrLayershell.namespace: "qs-todo-bg"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors.top: true; anchors.bottom: true
            anchors.left: true; anchors.right: true

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeWithAnimation()
            }
        }
    }

    // ── Main panel ──────────────────────────────────────────

    Variants {
        model: ScreenModel.targetScreens(Quickshell.screens, Quickshell.env("QS_TARGET_OUTPUT"))

        PanelWindow {
            id: panel
            required property ShellScreen modelData
            screen: modelData

            color: "transparent"
            WlrLayershell.namespace: "qs-todo"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            anchors.top: true; anchors.bottom: true
            anchors.left: true; anchors.right: true

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: function(event) { root.handleGlobalKeys(event) }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeWithAnimation()
                }
            }

            Rectangle {
                id: dialog
                anchors.centerIn: parent
                width: 420
                height: 480
                color: Theme.background
                radius: Theme.radiusXL
                border.color: Theme.outline
                border.width: 1

                opacity: root.panelOpacity
                scale: root.panelScale
                transform: Translate { y: root.panelY }

                layer.enabled: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: function(mouse) { mouse.accepted = true }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingXL
                    spacing: Theme.spacingM

                    // ── Header ──────────────────────────────

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingS

                        Text {
                            text: ""
                            font.family: "Symbols Nerd Font Mono"
                            font.pixelSize: 18
                            color: Theme.primary
                        }

                        Text {
                            text: "待办事项"
                            font.pixelSize: Theme.fontSizeL
                            font.bold: true
                            color: Theme.textPrimary
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.todos.filter(function(t) { return !t.done }).length + "/" + root.todos.length
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textMuted
                        }
                    }

                    // ── Separator ───────────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.outline
                    }

                    // ── Input ───────────────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        color: Theme.surface
                        radius: Theme.radiusM
                        border.color: inputField.activeFocus ? Theme.primary : Theme.outline
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingS
                            spacing: Theme.spacingS

                            TextInput {
                                id: inputField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Theme.fontSizeM
                                color: Theme.textPrimary
                                clip: true
                                selectByMouse: true

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "添加新任务..."
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontSizeM
                                    visible: !inputField.text && !inputField.activeFocus
                                }

                                Keys.onPressed: function(event) { root.handleGlobalKeys(event) }
                                Keys.onReturnPressed: { root.addTodo(text); text = "" }
                            }

                            Rectangle {
                                width: 30; height: 30
                                radius: Theme.radiusS
                                color: addBtnHover.hovered ? Theme.alpha(Theme.primary, 0.2) : Theme.alpha(Theme.primary, 0.1)

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "Symbols Nerd Font Mono"
                                    font.pixelSize: 14
                                    color: Theme.primary
                                }

                                HoverHandler { id: addBtnHover }
                                TapHandler {
                                    onTapped: { root.addTodo(inputField.text); inputField.text = "" }
                                }
                            }
                        }
                    }

                    // ── List ────────────────────────────────

                    ListView {
                        id: todoList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.todos

                        // Sort: undone first, then by creation time
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: Theme.textMuted
                            }
                        }

                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: todoList.width
                            height: 44
                            color: itemHover.hovered ? Theme.surfaceVariant : "transparent"
                            radius: Theme.radiusM

                            readonly property bool isDone: modelData.done

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacingM

                                // Checkbox
                                Rectangle {
                                    width: 20; height: 20
                                    radius: Theme.radiusS
                                    color: isDone ? Theme.success : "transparent"
                                    border.color: isDone ? Theme.success : Theme.outline
                                    border.width: isDone ? 0 : 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "Symbols Nerd Font Mono"
                                        font.pixelSize: 11
                                        color: Theme.background
                                        visible: isDone
                                    }

                                    HoverHandler { id: checkboxHover }
                                    TapHandler { onTapped: root.toggleTodo(modelData.id) }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.text
                                    font.pixelSize: Theme.fontSizeM
                                    color: isDone ? Theme.textMuted : Theme.textPrimary
                                    font.strikeout: isDone
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                // Delete button
                                Rectangle {
                                    width: 28; height: 28
                                    radius: Theme.radiusS
                                    color: delHover.hovered ? Theme.alpha(Theme.error, 0.15) : "transparent"
                                    opacity: itemHover.hovered ? 1 : 0

                                    Behavior on opacity { NumberAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "Symbols Nerd Font Mono"
                                        font.pixelSize: 12
                                        color: delHover.hovered ? Theme.error : Theme.textMuted
                                    }

                                    HoverHandler { id: delHover }
                                    TapHandler { onTapped: root.deleteTodo(modelData.id) }
                                }
                            }

                            HoverHandler { id: itemHover }
                        }

                        // Empty state
                        Text {
                            anchors.centerIn: parent
                            text: "暂无待办事项\n输入内容后按 Enter 添加"
                            font.pixelSize: Theme.fontSizeM
                            color: Theme.textMuted
                            horizontalAlignment: Text.AlignHCenter
                            lineHeight: 1.6
                            visible: root.todos.length === 0
                        }
                    }

                    // ── Footer ───────────────────────────────

                    RowLayout {
                        Layout.fillWidth: true

                        // Clear completed
                        Rectangle {
                            visible: root.todos.some(function(t) { return t.done })
                            height: 26
                            width: clearLabel.implicitWidth + Theme.spacingM * 2
                            radius: Theme.radiusS
                            color: clearHover.hovered ? Theme.surfaceVariant : "transparent"
                            border.color: Theme.outline
                            border.width: 1

                            Text {
                                id: clearLabel
                                anchors.centerIn: parent
                                text: "清除已完成"
                                font.pixelSize: Theme.fontSizeS
                                color: Theme.textSecondary
                            }

                            HoverHandler { id: clearHover }
                            TapHandler { onTapped: root.clearCompleted() }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Esc 关闭"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textMuted
                        }
                    }
                }
            }
        }
    }
}
