{ pkgs, ... }:
{
  programs.obs-studio.enable = true; # OBS 直播/录屏工具

  home.packages = with pkgs; [
    google-chrome # Google Chrome 浏览器
    splayer-next # SPlayer Next 音乐播放器（官方稳定版二进制）
    telegram-desktop # Telegram 桌面客户端
    kazumi # 番剧聚合与在线观看
  ];
}
