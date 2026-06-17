# Zed Editor — 高性能协作代码编辑器
# GUI 应用无法读取 shell profile 中的 sessionVariables，需要 wrapper 环境变量
{ pkgs, lib, ... }:
let
  claude-fish = pkgs.writeShellScript "claude-fish" ''
    exec ${pkgs.fish}/bin/fish -ic 'claude $argv' _ "$@"
  '';
  zed-editor-wrapped = pkgs.symlinkJoin {
    name = "zed-editor-wrapped";
    paths = [ pkgs.zed-editor ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --set CLAUDE_CODE_EXECUTABLE ${claude-fish}
    '';
  };
in
{
  home.packages = [ zed-editor-wrapped ];

  # 种子配置 — 仅在新机器首次部署时创建，之后 zed 可自由修改
  # 主题由 Noctalia 模板运行时写入 ~/.config/zed/themes/noctalia.json
  home.activation.seedZedConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ZED_JSON="$HOME/.config/zed/settings.json"
    if [ ! -f "$ZED_JSON" ]; then
      mkdir -p "$(dirname "$ZED_JSON")"
      cat > "$ZED_JSON" <<'JSON'
{
  "theme": {
    "mode": "system",
    "light": "Noctalia Light",
    "dark": "Noctalia Dark"
  }
}
JSON
    fi
  '';
}
