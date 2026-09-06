import QtQuick
import Quickshell
import Quickshell.Io
import "./TodoModel.js" as Model

QtObject {
    id: root
    property var todos: []
    property bool writable: false
    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share"
    property FileView file: FileView {
        path: root.dataHome + "/quickshell/todos.json"
        preload: true
        blockLoading: true
        atomicWrites: true
        printErrors: false
        onSaveFailed: function(error) { console.warn("[todo] save failed:", error) }
    }
    Component.onCompleted: {
        try {
            todos = Model.decode(file.text())
            writable = true
        } catch (error) {
            // Preserve a damaged file for recovery instead of overwriting it on the next edit.
            console.warn("[todo] refusing to overwrite invalid todos.json:", error)
        }
    }
    function commit(next) {
        if (!writable) return false
        todos = next
        file.setText(JSON.stringify({todos: todos}, null, 2))
        return true
    }
    function add(text) {
        var next = Model.add(todos, text, Date.now())
        return next !== todos && commit(next)
    }
    function toggle(id) { return commit(Model.toggle(todos, id)) }
    function remove(id) { return commit(Model.remove(todos, id)) }
    function clearCompleted() { return commit(Model.clearCompleted(todos)) }
}
