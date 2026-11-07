const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const root = process.argv[2];
const busctl = process.argv[3];
const media = require(root + "/resources/native/media-ctrl.node");

media.initialize();
media.enable();
setTimeout(() => {
  try {
    const args = ["--address=" + process.env.DBUS_SESSION_BUS_ADDRESS, "--no-pager"];
    const names = execFileSync(busctl, [...args, "--list"], { encoding: "utf8" });
    const line = names.split("\n").find(line => /org\.mpris\.MediaPlayer2\..*splayer/i.test(line));
    assert.ok(line, "SPlayer MPRIS service must be registered");
    const service = line.trim().split(/\s+/)[0];
    const identity = execFileSync(busctl, [
      ...args, "get-property", service, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2", "Identity"
    ], { encoding: "utf8" }).trim();
    // 桌面歌词按 identity / dbusName 中的 splayer 子串筛选播放器。
    assert.match(identity, /splayer/i);
    console.log("Private-session MPRIS:", service, identity);
  } finally {
    media.disable();
    media.shutdown();
  }
}, 500);
