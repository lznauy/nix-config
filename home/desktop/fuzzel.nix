# fuzzel - Wayland 应用启动器（配色由 noctalia 社区模板管理）
{ pkgs, ... }:

{
  home.packages = [ pkgs.fuzzel ];

  xdg.configFile."fuzzel/fuzzel.ini" = {
    force = true;  # 从 programs.fuzzel 迁移，覆盖旧文件
    text = ''
      # Noctalia 主题 — 此文件由 Noctalia 模板运行时写入
      include=~/.config/fuzzel/themes/noctalia

      [main]
      line-height=25
      fields=name,generic,comment,categories,filename,keywords
      terminal=kitty
      prompt=' ➜  '
      icon-theme=Papirus-Dark
      layer=top
      lines=10
      width=35
      horizontal-pad=25
      inner-pad=5

      [border]
      radius=15
      width=3
    '';
  };
}
