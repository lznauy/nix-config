const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
function load(file) {
  const context = vm.createContext({});
  vm.runInContext(fs.readFileSync(path.join(__dirname, "..", file), "utf8"), context);
  return context;
}
const model = load("home/desktop/quickshell/todo/TodoModel.js");
const palette = load("home/desktop/quickshell/shared/Palette.js");
const todo = {id: 100, text: "existing", done: false, createdAt: "2026-01-01", extra: "preserve"};
test("todo reads legacy arrays and object documents", () => {
  assert.equal(model.decode(JSON.stringify([todo]))[0].text, "existing");
  assert.equal(model.decode(JSON.stringify({todos: [todo]}))[0].id, 100);
  assert.equal(model.decode("").length, 0);
});
test("invalid todo data is rejected instead of converted into an empty document", () => {
  for (const raw of ["{", "null", "{}", '{"todos":[null]}', JSON.stringify([todo, todo])])
    assert.throws(() => model.decode(raw));
});
test("two additions in the same millisecond have distinct IDs", () => {
  const first = model.add([], "first", 100);
  const second = model.add(first, " second ", 100);
  assert.notEqual(second[0].id, second[1].id);
  assert.equal(second[1].text, "second");
  assert.equal(model.add(second, " ", 100), second);
});
test("editing todo does not mutate input or discard extra fields", () => {
  const updated = model.toggle([todo], 100);
  assert.equal(todo.done, false);
  assert.equal(updated[0].done, true);
  assert.equal(updated[0].extra, "preserve");
  assert.equal(model.clearCompleted(updated).length, 0);
  assert.equal(model.remove([todo], 100).length, 0);
});
test("theme parser accepts supported colors and rejects malformed values", () => {
  assert.equal(palette.isColorValue("#abcdef"), true);
  assert.equal(palette.isColorValue("#12345678"), true);
  assert.equal(palette.isColorValue("#xyz123"), false);
  assert.equal(palette.tomlColor('blue = "#123456"\n', "blue"), "#123456");
  assert.equal(palette.tomlColor('blue = "invalid"', "blue"), "");
});
