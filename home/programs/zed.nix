# Zed Editor — 高性能协作代码编辑器
# GUI 应用无法读取 shell profile 中的 sessionVariables，需要 wrapper 环境变量
{ pkgs, ... }:
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
}
