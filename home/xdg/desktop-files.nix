{
  xdg.desktopEntries."yazi" = {
    name = "Yazi";
    genericName = "Terminal File Manager";
    comment = "Blazing fast file manager written in Rust";
    exec = "yazi %u";
    terminal = true;
    type = "Application";
    icon = "utilities-terminal";
    categories = [
      "System"
      "FileTools"
      "FileManager"
      "TerminalEmulator"
    ];
    settings.Keywords = "file;manager;browser;terminal;";
  };

  xdg.desktopEntries."xterm" = {
    name = "XTerm";
    comment = "Terminal emulator for X";
    exec = "xterm";
    terminal = false;
    type = "Application";
    icon = "utilities-terminal";
    categories = [
      "System"
      "TerminalEmulator"
    ];
  };

  xdg.desktopEntries."kbd-layout-viewer5" = {
    name = "Keyboard layout viewer";
    genericName = "Keyboard Layout Tester";
    comment = "View keyboard layout";
    exec = "kbd-layout-viewer5";
    icon = "preferences-desktop-keyboard";
    terminal = false;
    type = "Application";
    categories = [
      "Qt"
      "KDE"
      "Utility"
    ];
  };
}
