# XDG Autostart — 统一管理所有开机自启程序
# 放入 ~/.config/autostart/，所有桌面环境/合成器通用
{ ... }:
{
  xdg.configFile = {
    "autostart/clipse.desktop".text = ''
      [Desktop Entry]
      Categories=Utility
      Comment=剪贴板管理器
      Exec=clipse -listen
      Icon=clipse
      Name=Clipse
      StartupNotify=false
      Terminal=false
      Type=Application
    '';

    "autostart/blueman-applet.desktop".text = ''
      [Desktop Entry]
      Categories=GNOME;GTK;Settings;HardwareSettings;
      Comment=蓝牙管理面板小程序
      Exec=blueman-applet
      Icon=blueman
      Name=蓝牙管理
      StartupNotify=false
      Terminal=false
      Type=Application
    '';

    "autostart/qs-island.desktop".text = ''
      [Desktop Entry]
      Categories=Utility
      Comment=桌面歌词 / 时钟悬浮组件
      Exec=qs-island
      Icon=qs-island
      Name=Dynamic Island
      StartupNotify=false
      Terminal=false
      Type=Application
      Version=1.5
    '';
  };
}
