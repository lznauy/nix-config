{
  config,
  lib,
  pkgs,
  ...
}:
let
  files = [
    "Content/LyricsController.qml"
    "shell.qml"
    "Common/Appearance.qml"
    "Common/DynamicIslandMotion.qml"
    "Common/Sizes.qml"
    "Common/Paths.qml"
    "Common/qmldir"
    "Content/ClockContent.qml"
    "Content/LyricsContent.qml"
    "Content/TranslationConfig.qml"
    "Content/TranslationContent.qml"
    "Content/qmldir"
    "scripts/lyrics_fetcher.py"
  ];
  islandDir = "${config.xdg.configHome}/quickshell/dynamic-island";
  islandIcon = "${pkgs.quickshell}/share/icons/hicolor/scalable/apps/org.quickshell.svg";
in
{
  xdg.configFile =
    builtins.listToAttrs (
      map (
        name:
        lib.nameValuePair "quickshell/dynamic-island/${name}" {
          source = ./. + "/${name}";
          # Preserve the existing overwrite policy.
          force = !(builtins.elem name [ "Content/LyricsController.qml" ]);
        }
      ) files
    )
    // {
      "autostart/qs-island.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=qs-island
        Exec=qs-island
        Icon=qs-island
        Terminal=false
        StartupNotify=false
      '';
    };

  # Install the quickshell icon so the desktop entry can find it
  xdg.dataFile."icons/hicolor/scalable/apps/qs-island.svg".source = islandIcon;

  home.packages = [
    (pkgs.writeShellApplication {
      name = "qs-lyrics";
      runtimeInputs = [ pkgs.python3 ];
      text = ''
        exec python3 ${./scripts/lyrics_fetcher.py} "$@"
      '';
    })
    (pkgs.writeShellScriptBin "qs-island" ''
      mkdir -p ${config.xdg.stateHome}/quickshell/dynamic-island
      exec ${pkgs.quickshell}/bin/quickshell \
        --path ${islandDir}/shell.qml
    '')
  ];

  xdg.desktopEntries."qs-island" = {
    name = "Desktop Lyrics";
    exec = "qs-island";
    icon = "qs-island";
    type = "Application";
    terminal = false;
    startupNotify = false;
    categories = [ "Utility" ];
    comment = "透明、可拖动的桌面歌词悬浮层";
  };
}
