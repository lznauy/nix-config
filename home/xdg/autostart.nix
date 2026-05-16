{ config, pkgs, ... }:

{
  # 启用 XDG 自动启动，会在桌面环境就绪后启动以下应用
  xdg.autostart.enable = true;

  xdg.autostart.entries = [
    # "${pkgs.kitty}/share/applications/kitty.desktop"
    # "${pkgs.google-chrome}/share/applications/google-chrome.desktop"
    # "${pkgs.telegram-desktop}/share/applications/telegram-desktop.desktop"
    "${pkgs.blueman}/etc/xdg/autostart/blueman.desktop"
  ];
}
