{ lib, pkgs, ... }:
{
  # 生成 ~/.config/mimeapps.list
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;

    # 默认应用程序关联
    defaultApplications = {
      # 浏览器
      "text/html" = [ "google-chrome.desktop" ];
      "text/xml" = [ "google-chrome.desktop" ];
      "application/pdf" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];

      # SPlayer Next 处理音频与网易云链接；视频不再误指向音乐播放器。
      "x-scheme-handler/orpheus" = [ pkgs.splayer-next.desktopId ];

      # 图片
      "image/png" = [ "google-chrome.desktop" ];
      "image/jpeg" = [ "google-chrome.desktop" ];
      "image/gif" = [ "google-chrome.desktop" ];
      "image/webp" = [ "google-chrome.desktop" ];

      # 文件管理器
      "inode/directory" = [ "yazi.desktop" ];
    }
    // lib.genAttrs pkgs.splayer-next.audioMimeTypes (_: [ pkgs.splayer-next.desktopId ]);
  };
}
