# WeChat — 微信
# 跑在 XWayland 上，waylandFrontend=true 时 QT_IM_MODULE/GTK_IM_MODULE 不会被全局设置，需要单独包装
{ pkgs, ... }:
let
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
in
{
  home.packages = [ wechat-im ];
}
