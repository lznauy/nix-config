{ ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./stylix/default.nix
    ./base/fcitx5.nix
    ./desktop/niri/default.nix
    ./desktop/noctalia/default.nix
    # hyprlock 已停用：与 noctalia v5 内置锁屏竞争 ext-session-lock，
    # 睡眠时 noctalia 重复请求锁屏触发 duplicate_output(code=3) 被 niri 杀掉。
    # 现在由 noctalia 承担锁屏（监听 logind Lock 信号）。
    ./desktop/quickshell
    ./desktop/fuzzel.nix
    ./desktop/kitty.nix
    ./desktop/gtk.nix
    ./shell/default.nix
    ./xdg/default.nix
    ./programs/qutebrowser/default.nix
    ./programs/ai/default.nix
    ./programs/tools.nix
    ./programs/wemeet.nix
    ./desktop/bluetooth.nix
    ./programs/flatpak.nix
    ./programs/apps.nix
    ./programs/qq
    ./programs/onlyoffice.nix
    ./programs/wechat.nix
    ./programs/zed.nix
    ./programs/vscode.nix
    ./programs/asciinema.nix
    ./programs/btm.nix
    ./programs/devshell/home.nix
    ./programs/fastfetch.nix
    ./programs/git.nix
    ./programs/nh.nix
    ./programs/nixvim/default.nix
    ./programs/system-tui.nix
  ];

}
