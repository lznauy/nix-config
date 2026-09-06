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

      # 视频/音频
      "video/*" = [ "splayer.desktop" ];
      "audio/*" = [ "splayer.desktop" ];

      # 图片
      "image/png" = [ "google-chrome.desktop" ];
      "image/jpeg" = [ "google-chrome.desktop" ];
      "image/gif" = [ "google-chrome.desktop" ];
      "image/webp" = [ "google-chrome.desktop" ];

      # 文件管理器
      "inode/directory" = [ "yazi.desktop" ];
    };
  };
}
