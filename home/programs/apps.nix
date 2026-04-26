{ pkgs, ... }:

{
  programs.obs-studio.enable = true; # OBS 直播/录屏工具

  home.packages = with pkgs; [
    google-chrome # Google Chrome 浏览器
    splayer # SPlayer 视频播放器
    qq # QQ 即时通讯
    telegram-desktop # Telegram 桌面客户端
    kazumi # 番剧聚合与在线观看
  ];
}
