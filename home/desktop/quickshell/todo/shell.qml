import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "./ScreenModel.js" as ScreenModel

ShellRoot {
    id: root

    property bool opened: false
    property var todos: []
    readonly property string dataHome: {
        var configured = Quickshell.env("XDG_DATA_HOME")
        return configured !== "" ? configured : Quickshell.env("HOME") + "/.local/share"
    }
    readonly property string dataFile: dataHome + "/quickshell/todos.json"
    readonly property int pendingCount: todos.filter(function(todo) { return !todo.done }).length

    signal panelOpened

    Theme { id: theme }

    Component.onCompleted: loadData(todoFile.text())

    IpcHandler {
        target: "todo"

        function reveal(): void { root.showPanel() }
        function hide(): void { root.hidePanel() }
        function toggle(): void { root.togglePanel() }
    }

    FileView {
        id: todoFile
        path: root.dataFile
        preload: true
        blockLoading: true
        atomicWrites: true
        printErrors: false

        onSaveFailed: function(error) {
            console.warn("[todo] save failed:", error)
        }
    }

    function loadData(raw) {
        if (!raw || raw.length === 0) {
            todos = []
            return
        }

        try {
            var data = JSON.parse(raw)
            var loadedTodos = Array.isArray(data) ? data : data.todos
            todos = Array.isArray(loadedTodos) ? loadedTodos : []
        } catch (error) {
            todos = []
            console.warn("[todo] invalid todos.json:", error)
        }
    }

    function saveData() {
        // FileView writes asynchronously and atomically; the UI never waits for disk I/O.
        todoFile.setText(JSON.stringify({todos: todos}, null, 2))
    }

    function showPanel() {
        if (opened) return
        opened = true
        panelOpened()
    }

    function hidePanel() {
        opened = false
    }

    function togglePanel() {
        if (opened) hidePanel()
        else showPanel()
    }

    function handleGlobalKeys(event) {
        if (event.key === Qt.Key_Escape) {
            hidePanel()
            event.accepted = true
        }
    }

    function addTodo(text) {
        var cleanText = text.trim()
        if (cleanText === "") return false

        todos = todos.concat([{
            id: Date.now(),
            text: cleanText,
            done: false,
            createdAt: new Date().toISOString()
        }])
        saveData()
        return true
    }

    function toggleTodo(id) {
        todos = todos.map(function(todo) {
            if (todo.id !== id) return todo
            return {
                id: todo.id,
                text: todo.text,
                done: !todo.done,
                createdAt: todo.createdAt
            }
        })
        saveData()
    }

    function deleteTodo(id) {
        todos = todos.filter(function(todo) { return todo.id !== id })
        saveData()
    }

    function clearCompleted() {
        todos = todos.filter(function(todo) { return !todo.done })
        saveData()
    }

    Variants {
        model: ScreenModel.targetScreens(Quickshell.screens, Quickshell.env("QS_TARGET_OUTPUT"))

        PanelWindow {
            id: panel
            required property ShellScreen modelData
            screen: modelData
            visible: root.opened

            color: theme.withAlpha(theme.shadow, theme.darkMode ? 0.42 : 0.24)
            WlrLayershell.namespace: "qs-todo"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: function(event) { root.handleGlobalKeys(event) }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.hidePanel()
                }
            }

            Rectangle {
                id: dialog
                anchors.centerIn: parent
                width: Math.min(440, parent.width - theme.spacingXL * 2)
                height: Math.min(520, parent.height - theme.spacingXL * 2)
                color: theme.surface
                radius: theme.radiusL
                border.color: theme.withAlpha(theme.outline, 0.78)
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: function(mouse) { mouse.accepted = true }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: theme.spacingXL
                    spacing: theme.spacingM

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: theme.spacingM

                        Rectangle {
                            width: 36
                            height: 36
                            radius: theme.radiusS
                            color: theme.withAlpha(theme.primary, 0.14)

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font Mono"
                                font.pixelSize: theme.fontSizeXL
                                color: theme.primary
                            }
                        }

                        ColumnLayout {
                            spacing: 0

                            Text {
                                text: "待办事项"
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeXL
                                font.weight: Font.DemiBold
                                color: theme.surfaceForeground
                            }

                            Text {
                                text: root.pendingCount === 0 ? "今天已全部完成" : "还有 " + root.pendingCount + " 项待处理"
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeS
                                color: theme.surfaceVariantForeground
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            height: 28
                            width: countLabel.implicitWidth + theme.spacingL * 2
                            radius: theme.radiusS
                            color: theme.surfaceVariant

                            Text {
                                id: countLabel
                                anchors.centerIn: parent
                                text: root.pendingCount + " / " + root.todos.length
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeS
                                font.weight: Font.Medium
                                color: theme.surfaceVariantForeground
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: theme.radiusS
                            color: closeHover.hovered ? theme.withAlpha(theme.hover, 0.16) : "transparent"
                            scale: closeTap.pressed ? 0.96 : 1
                            Accessible.role: Accessible.Button
                            Accessible.name: "关闭待办事项"

                            Behavior on scale {
                                NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: "Symbols Nerd Font Mono"
                                font.pixelSize: theme.fontSizeL
                                color: closeHover.hovered ? theme.hover : theme.surfaceVariantForeground
                            }

                            HoverHandler { id: closeHover }
                            TapHandler { id: closeTap; onTapped: root.hidePanel() }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: theme.withAlpha(theme.outline, 0.55)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: theme.surfaceVariant
                        radius: theme.radiusM
                        border.color: inputField.activeFocus ? theme.primary : theme.withAlpha(theme.outline, 0.72)
                        border.width: inputField.activeFocus ? 2 : 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: theme.spacingL
                            anchors.rightMargin: theme.spacingXS
                            spacing: theme.spacingS

                            Text {
                                text: ""
                                font.family: "Symbols Nerd Font Mono"
                                font.pixelSize: theme.fontSizeL
                                color: inputField.activeFocus ? theme.primary : theme.surfaceVariantForeground
                            }

                            TextInput {
                                id: inputField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: Text.AlignVCenter
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeM
                                color: theme.surfaceForeground
                                selectionColor: theme.primary
                                selectedTextColor: theme.primaryForeground
                                clip: true
                                selectByMouse: true
                                Accessible.name: "新待办内容"

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "快速添加一项任务"
                                    color: theme.withAlpha(theme.surfaceVariantForeground, 0.72)
                                    font.family: theme.fontFamily
                                    font.pixelSize: theme.fontSizeM
                                    visible: inputField.text.length === 0
                                }

                                Connections {
                                    target: root
                                    function onPanelOpened() {
                                        inputField.text = ""
                                        Qt.callLater(function() { inputField.forceActiveFocus() })
                                    }
                                }

                                Keys.onPressed: function(event) { root.handleGlobalKeys(event) }
                                Keys.onReturnPressed: {
                                    if (root.addTodo(text)) text = ""
                                }
                                Keys.onEnterPressed: {
                                    if (root.addTodo(text)) text = ""
                                }
                            }

                            Rectangle {
                                width: 40
                                height: 40
                                radius: theme.radiusS
                                color: inputField.text.trim() === ""
                                    ? theme.withAlpha(theme.surfaceVariantForeground, 0.12)
                                    : (addHover.hovered ? theme.hover : theme.primary)
                                scale: addTap.pressed ? 0.96 : 1
                                Accessible.role: Accessible.Button
                                Accessible.name: "添加待办"

                                Behavior on scale {
                                    NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: "Symbols Nerd Font Mono"
                                    font.pixelSize: theme.fontSizeL
                                    color: inputField.text.trim() === ""
                                        ? theme.withAlpha(theme.surfaceVariantForeground, 0.5)
                                        : (addHover.hovered ? theme.hoverForeground : theme.primaryForeground)
                                }

                                HoverHandler { id: addHover }
                                TapHandler {
                                    id: addTap
                                    enabled: inputField.text.trim() !== ""
                                    onTapped: {
                                        if (root.addTodo(inputField.text)) inputField.text = ""
                                    }
                                }
                            }
                        }
                    }

                    ListView {
                        id: todoList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: theme.spacingXS
                        model: root.todos
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: theme.withAlpha(theme.surfaceVariantForeground, 0.6)
                            }
                        }

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            readonly property bool isDone: modelData.done
                            width: todoList.width
                            height: 48
                            color: itemHover.hovered ? theme.withAlpha(theme.hover, 0.12) : "transparent"
                            radius: theme.radiusS

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: theme.spacingXS
                                anchors.rightMargin: theme.spacingXS
                                spacing: theme.spacingS

                                Item {
                                    width: 40
                                    height: 40

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 22
                                        height: 22
                                        radius: theme.radiusXS
                                        color: isDone ? theme.primary : "transparent"
                                        border.color: isDone ? theme.primary : theme.outline
                                        border.width: isDone ? 0 : 2
                                        scale: checkboxTap.pressed ? 0.9 : 1

                                        Behavior on scale {
                                            NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: ""
                                            font.family: "Symbols Nerd Font Mono"
                                            font.pixelSize: theme.fontSizeS
                                            color: theme.primaryForeground
                                            visible: isDone
                                        }
                                    }

                                    Accessible.role: Accessible.CheckBox
                                    Accessible.name: (isDone ? "标为未完成：" : "标为已完成：") + modelData.text
                                    HoverHandler { id: checkboxHover }
                                    TapHandler { id: checkboxTap; onTapped: root.toggleTodo(modelData.id) }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.text
                                    font.family: theme.fontFamily
                                    font.pixelSize: theme.fontSizeM
                                    color: isDone ? theme.withAlpha(theme.surfaceVariantForeground, 0.62) : theme.surfaceForeground
                                    font.strikeout: isDone
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: theme.radiusS
                                    color: deleteHover.hovered ? theme.withAlpha(theme.error, 0.16) : "transparent"
                                    opacity: itemHover.hovered || deleteTap.pressed ? 1 : 0
                                    scale: deleteTap.pressed ? 0.96 : 1
                                    Accessible.role: Accessible.Button
                                    Accessible.name: "删除待办：" + modelData.text

                                    Behavior on opacity {
                                        NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                                    }
                                    Behavior on scale {
                                        NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "Symbols Nerd Font Mono"
                                        font.pixelSize: theme.fontSizeM
                                        color: deleteHover.hovered ? theme.error : theme.surfaceVariantForeground
                                    }

                                    HoverHandler { id: deleteHover }
                                    TapHandler { id: deleteTap; onTapped: root.deleteTodo(modelData.id) }
                                }
                            }

                            HoverHandler { id: itemHover }
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - theme.spacingXL * 2
                            text: "列表是空的\n在上方输入后按 Enter"
                            font.family: theme.fontFamily
                            font.pixelSize: theme.fontSizeM
                            color: theme.withAlpha(theme.surfaceVariantForeground, 0.72)
                            horizontalAlignment: Text.AlignHCenter
                            lineHeight: 1.45
                            visible: root.todos.length === 0
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: theme.withAlpha(theme.outline, 0.38)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: theme.spacingS

                        Rectangle {
                            visible: root.todos.some(function(todo) { return todo.done })
                            height: 40
                            width: clearLabel.implicitWidth + theme.spacingL * 2
                            radius: theme.radiusS
                            color: clearHover.hovered ? theme.withAlpha(theme.hover, 0.14) : "transparent"
                            scale: clearTap.pressed ? 0.96 : 1
                            Accessible.role: Accessible.Button
                            Accessible.name: "清除全部已完成待办"

                            Behavior on scale {
                                NumberAnimation { duration: theme.animationFaster; easing.type: Easing.OutCubic }
                            }

                            Text {
                                id: clearLabel
                                anchors.centerIn: parent
                                text: "清除已完成"
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeS
                                font.weight: Font.Medium
                                color: clearHover.hovered ? theme.hover : theme.surfaceVariantForeground
                            }

                            HoverHandler { id: clearHover }
                            TapHandler { id: clearTap; onTapped: root.clearCompleted() }
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: theme.spacingXS

                            Rectangle {
                                width: escLabel.implicitWidth + theme.spacingM * 2
                                height: 24
                                radius: theme.radiusXS
                                color: theme.surfaceVariant

                                Text {
                                    id: escLabel
                                    anchors.centerIn: parent
                                    text: "Esc"
                                    font.family: theme.fontFamily
                                    font.pixelSize: theme.fontSizeXS
                                    font.weight: Font.Medium
                                    color: theme.surfaceVariantForeground
                                }
                            }

                            Text {
                                text: "关闭"
                                font.family: theme.fontFamily
                                font.pixelSize: theme.fontSizeS
                                color: theme.withAlpha(theme.surfaceVariantForeground, 0.7)
                            }
                        }
                    }
                }
            }
        }
    }
}
