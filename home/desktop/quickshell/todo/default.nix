{ config, pkgs, ... }:
let
  quickshell = pkgs.quickshell;
  todoLauncher = pkgs.writeShellScriptBin "qs-todo" ''
    if ${quickshell}/bin/qs ipc --config todo call todo toggle >/dev/null 2>&1; then
      exit 0
    fi

    ${pkgs.systemd}/bin/systemctl --user start quickshell-todo.service

    attempt=0
    while [ "$attempt" -lt 50 ]; do
      if ${quickshell}/bin/qs ipc --config todo call todo reveal >/dev/null 2>&1; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.01
      attempt=$((attempt + 1))
    done

    echo "qs-todo: quickshell-todo.service did not become ready" >&2
    exit 1
  '';
in
{
  xdg.configFile = {
    "quickshell/todo/shell.qml" = { source = ./shell.qml; force = true; };
    "quickshell/todo/Theme.qml" = { source = ./Theme.qml; force = true; };
    "quickshell/todo/ScreenModel.js" = { source = ./ScreenModel.js; force = true; };
  };

  home.packages = [ todoLauncher ];

  systemd.user.services.quickshell-todo = {
    Unit = {
      Description = "Quickshell todo panel";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
      X-Restart-Triggers = map toString [
        ./shell.qml
        ./Theme.qml
        ./ScreenModel.js
      ];
    };

    Service = {
      ExecStart = "${quickshell}/bin/quickshell --config todo";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
