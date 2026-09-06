{
  config,
  lib,
  pkgs,
  ...
}:
let
  files = [
    "TodoModel.js"
    "TodoStore.qml"
    "shell.qml"
    "Theme.qml"
    "ScreenModel.js"
  ];
  inherit (pkgs) quickshell;
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
  xdg.configFile =
    builtins.listToAttrs (
      map (
        name:
        lib.nameValuePair "quickshell/todo/${name}" {
          source = ./. + "/${name}";
          # Preserve the existing overwrite policy.
          force =
            !(builtins.elem name [
              "TodoModel.js"
              "TodoStore.qml"
            ]);
        }
      ) files
    )
    // {
      # Keep script imports beside their QML consumer. Home Manager links each
      # source into a separate store path, so cross-directory relative imports
      # cannot reliably resolve through the deployed symlinks.
      "quickshell/todo/Palette.js".source = ../shared/Palette.js;
    };

  home.packages = [ todoLauncher ];

  systemd.user.services.quickshell-todo = {
    Unit = {
      Description = "Quickshell todo panel";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
      X-Restart-Triggers = map toString (map (name: ./. + "/${name}") files ++ [ ../shared/Palette.js ]);
    };

    Service = {
      ExecStart = "${quickshell}/bin/quickshell --config todo";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
