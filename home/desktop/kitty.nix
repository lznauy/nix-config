# kitty - GPU 加速终端模拟器（配色由 noctalia 模板管理，字体由 Stylix 全局管理）
{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    extraConfig = ''
      # Noctalia 主题 — themes/noctalia.conf 由 Noctalia 模板运行时写入
      include themes/noctalia.conf
    '';

    settings = {
      dynamic_background_opacity = "yes";
      hide_window_decorations = "yes";
      background_opacity = "0.95";
      tab_bar_edge = "bottom";
      tab_bar_min_tabs = "1";
      confirm_os_window_close = "0";
      tab_powerline_style = "slanted";
      allow_hyperlinks = "no";
    };
  };
}
