{ config, pkgs, ... }:
let
  islandDir = "${config.xdg.configHome}/quickshell/dynamic-island";
  islandIcon = "${pkgs.quickshell}/share/icons/hicolor/scalable/apps/org.quickshell.svg";
in
{
  xdg.configFile = {
    "quickshell/dynamic-island/shell.qml" = { source = ./shell.qml; force = true; };
    "quickshell/dynamic-island/Common/Appearance.qml" = { source = ./Common/Appearance.qml; force = true; };
    "quickshell/dynamic-island/Common/Animations.qml" = { source = ./Common/Animations.qml; force = true; };
    "quickshell/dynamic-island/Common/DynamicIslandMotion.qml" = { source = ./Common/DynamicIslandMotion.qml; force = true; };
    "quickshell/dynamic-island/Common/Sizes.qml" = { source = ./Common/Sizes.qml; force = true; };
    "quickshell/dynamic-island/Common/Paths.qml" = { source = ./Common/Paths.qml; force = true; };
    "quickshell/dynamic-island/Common/qmldir" = { source = ./Common/qmldir; force = true; };
    "quickshell/dynamic-island/Content/ClockContent.qml" = { source = ./Content/ClockContent.qml; force = true; };
    "quickshell/dynamic-island/Content/LyricsContent.qml" = { source = ./Content/LyricsContent.qml; force = true; };
    "quickshell/dynamic-island/Content/qmldir" = { source = ./Content/qmldir; force = true; };
    "quickshell/dynamic-island/scripts/lyrics_fetcher.py" = { source = ./scripts/lyrics_fetcher.py; force = true; };
  };

  # Install the quickshell icon so the desktop entry can find it
  xdg.dataFile."icons/hicolor/scalable/apps/qs-island.svg".source = islandIcon;

  # Autostart entry — written directly to ensure it always exists
  xdg.configFile."autostart/qs-island.desktop".text = ''
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

  home.packages = [
    (pkgs.writeShellScriptBin "qs-island" ''
      exec ${pkgs.quickshell}/bin/quickshell \
        --path ${islandDir}/shell.qml
    '')
  ];

  xdg.desktopEntries."qs-island" = {
    name = "Dynamic Island";
    exec = "qs-island";
    icon = "qs-island";
    type = "Application";
    terminal = false;
    startupNotify = false;
    categories = [ "Utility" ];
    comment = "桌面歌词 / 时钟悬浮组件";
  };
}
