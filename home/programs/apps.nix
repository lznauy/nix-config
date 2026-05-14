{ pkgs, ... }:

let
  # WeChat 跑在 XWayland 上，但 waylandFrontend=true 时
  # QT_IM_MODULE/GTK_IM_MODULE 不会被全局设置，需要单独包装
  wechat-im = pkgs.symlinkJoin {
    name = "wechat-im";
    paths = [ pkgs.wechat ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wechat \
        --set QT_IM_MODULE fcitx \
        --set GTK_IM_MODULE fcitx
    '';
  };

  # GUI 应用无法读取 shell profile 中的 sessionVariables
  # 必须 wrapper 环境变量到二进制中
  zed-editor-wrapped = pkgs.symlinkJoin {
    name = "zed-editor-wrapped";
    paths = [ pkgs.zed-editor ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --set CLAUDE_CODE_EXECUTABLE ${pkgs.claude-code}/bin/claude
    '';
  };
in
{
  programs.obs-studio.enable = true; # OBS 直播/录屏工具

  home.packages = with pkgs; [
    google-chrome # Google Chrome 浏览器
    splayer # SPlayer 视频播放器
    qq # QQ 即时通讯
    telegram-desktop # Telegram 桌面客户端
    kazumi # 番剧聚合与在线观看
    zed-editor-wrapped # 高性能协作代码编辑器
    wechat-im # 微信
  ];
}
