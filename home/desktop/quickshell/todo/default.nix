{ config, pkgs, ... }:
{
  xdg.configFile = {
    "quickshell/todo/shell.qml" = { source = ./shell.qml; force = true; };
    "quickshell/todo/Theme.js" = { source = ./Theme.js; force = true; };
    "quickshell/todo/ScreenModel.js" = { source = ./ScreenModel.js; force = true; };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "qs-todo" ''
      mkdir -p ~/.local/share/quickshell
      exec ${pkgs.quickshell}/bin/quickshell \
        -p ${config.xdg.configHome}/quickshell/todo/shell.qml
    '')
  ];
}
