// Pure model functions, shared by QML and the Node regression tests.
function decode(raw) {
    if (!raw || raw.trim() === "") return [];
    var data = JSON.parse(raw);
    var todos = Array.isArray(data) ? data : data && data.todos;
    if (!Array.isArray(todos)) throw new Error("Invalid todo document");
    var ids = {};
    todos.forEach(function(todo) {
        if (!todo || typeof todo.text !== "string" || typeof todo.done !== "boolean"
                || typeof todo.id !== "number" || !isFinite(todo.id) || ids[todo.id])
            throw new Error("Invalid or duplicate todo");
        ids[todo.id] = true;
    });
    return todos;
}
function add(todos, text, now) {
    var clean = text.trim();
    if (!clean) return todos;
    var id = todos.reduce(function(value, todo) { return Math.max(value, todo.id + 1); }, now);
    return todos.concat([{id: id, text: clean, done: false, createdAt: new Date(now).toISOString()}]);
}
function toggle(todos, id) {
    return todos.map(function(todo) {
        if (todo.id !== id) return todo;
        return Object.assign({}, todo, {done: !todo.done});
    });
}
function remove(todos, id) { return todos.filter(function(todo) { return todo.id !== id; }); }
function clearCompleted(todos) { return todos.filter(function(todo) { return !todo.done; }); }
