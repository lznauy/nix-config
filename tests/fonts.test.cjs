const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execFileSync } = require("node:child_process");
test("font activation preserves unrelated fonts and only invalidates cache on changes", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "onlyoffice-test-"));
  try {
    const data = path.join(root, "data with spaces");
    const source = path.join(root, "source");
    const next = path.join(root, "next");
    const cache = path.join(data, "onlyoffice/desktopeditors/data/fonts");
    for (const p of [source, next]) fs.mkdirSync(path.join(p, "share/fonts"), {recursive: true});
    fs.mkdirSync(cache, {recursive: true});
    fs.mkdirSync(path.join(data, "fonts"), {recursive: true});
    fs.writeFileSync(path.join(data, "fonts/personal.ttf"), "mine");
    fs.writeFileSync(path.join(source, "share/fonts/old.ttf"), "old");
    fs.writeFileSync(path.join(next, "share/fonts/new.ttf"), "new");
    const run = src => execFileSync("bash", [path.join(__dirname, "../home/programs/onlyoffice-fonts.sh"), data, src]);
    run(source);
    fs.writeFileSync(path.join(cache, "AllFonts.js"), "keep on unchanged source");
    run(source);
    assert.equal(fs.existsSync(path.join(cache, "AllFonts.js")), true);
    run(next);
    assert.equal(fs.existsSync(path.join(cache, "AllFonts.js")), false);
    assert.equal(fs.existsSync(path.join(data, "fonts/onlyoffice-nix/old.ttf")), false);
    assert.equal(fs.readFileSync(path.join(data, "fonts/onlyoffice-nix/new.ttf"), "utf8"), "new");
    assert.equal(fs.readFileSync(path.join(data, "fonts/personal.ttf"), "utf8"), "mine");
  } finally { fs.rmSync(root, {recursive: true, force: true}); }
});
