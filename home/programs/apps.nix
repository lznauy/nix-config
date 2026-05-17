{ config, lib, pkgs, ... }:

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

  # OnlyOffice 使用 FHS 沙箱运行，不使用系统 fontconfig
  # 直接扫描 ~/.local/share/fonts/，需要拷贝非可变 TrueType CJK 字体
  home.activation.linkOnlyofficeFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fonts_dir="$HOME/.local/share/fonts"
    $DRY_RUN_CMD mkdir -p $fonts_dir
    for f in ${pkgs.lxgw-wenkai}/share/fonts/truetype/*.ttf; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    for f in ${pkgs.wqy_microhei}/share/fonts/truetype/*.ttc; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    for f in ${pkgs.arphic-ukai}/share/fonts/truetype/*.ttc; do
      $DRY_RUN_CMD cp -f "$f" "$fonts_dir/"
    done
    # 清除 OnlyOffice 字体缓存，强制重新扫描
    oo_fonts_cache="$HOME/.local/share/onlyoffice/desktopeditors/data/fonts"
    $DRY_RUN_CMD rm -f "$oo_fonts_cache/AllFonts.js" "$oo_fonts_cache/AllFonts.js."*
    $DRY_RUN_CMD rm -f "$oo_fonts_cache/fonts.log" "$oo_fonts_cache/font_selection.bin"
  '';

  home.packages = with pkgs; [
    google-chrome # Google Chrome 浏览器
    splayer # SPlayer 视频播放器
    qq # QQ 即时通讯
    telegram-desktop # Telegram 桌面客户端
    kazumi # 番剧聚合与在线观看
    zed-editor-wrapped # 高性能协作代码编辑器
    wechat-im # 微信
    onlyoffice-desktopeditors # OnlyOffice 桌面办公套件
  ];
}
