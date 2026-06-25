{ pkgs, ... }:

{
  xdg.dataFile."applications/yazi.desktop".source = pkgs.writeTextFile {
    name = "yazi.desktop";
    text = ''
      [Desktop Entry]
      Name=Yazi
      GenericName=Terminal File Manager
      Comment=Blazing fast file manager written in Rust
      Exec=yazi %u
      Terminal=true
      Type=Application
      Icon=utilities-terminal
      Categories=System;FileTools;FileManager;TerminalEmulator;
      Keywords=file;manager;browser;terminal;
    '';
  };

  xdg.dataFile."applications/xterm.desktop".source = pkgs.writeTextFile {
    name = "xterm.desktop";
    text = ''
      [Desktop Entry]
      Name=XTerm
      Comment=Terminal emulator for X
      Exec=xterm
      Terminal=false
      Type=Application
      Icon=utilities-terminal
      Categories=System;TerminalEmulator;
    '';
  };

  xdg.dataFile."applications/blueman-adapters.desktop".source = pkgs.writeTextFile {
    name = "blueman-adapters.desktop";
    text = ''
      [Desktop Entry]
      Name=蓝牙适配器
      Name[zh_CN]=蓝牙适配器
      Name[en]=Bluetooth Adapters
      Comment=设置蓝牙适配器属性
      Comment[zh_CN]=设置蓝牙适配器属性
      Exec=blueman-adapters
      Icon=preferences-system-bluetooth
      Terminal=false
      Type=Application
      Categories=Settings;HardwareSettings;GTK;
      StartupNotify=true
    '';
  };

  xdg.dataFile."applications/wemeetapp.desktop".source = pkgs.writeTextFile {
    name = "wemeetapp.desktop";
    text = ''
      [Desktop Entry]
      Name=腾讯会议
      Name[zh_CN]=腾讯会议
      Name[en]=Tencent Meeting
      Comment=腾讯会议 Linux 版
      Comment[zh_CN]=腾讯会议 Linux 版
      Exec=wemeet-xwayland %u
      Icon=wemeet
      Type=Application
      Terminal=false
      Categories=AudioVideo;Network;
      MimeType=x-scheme-handler/wemeet;
      StartupWMClass=wemeetapp
    '';
  };

  xdg.dataFile."applications/kbd-layout-viewer5.desktop".source = pkgs.writeTextFile {
    name = "kbd-layout-viewer5.desktop";
    text = ''
      [Desktop Entry]
      Name=Keyboard layout viewer
      GenericName=Keyboard Layout Tester
      Comment=View keyboard layout
      Exec=kbd-layout-viewer5
      Icon=preferences-desktop-keyboard
      Terminal=false
      Type=Application
      Categories=Qt;KDE;Utility;
    '';
  };
}
