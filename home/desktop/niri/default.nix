{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    grim # Wayland 截图工具
    slurp # Wayland 区域选择工具
    wl-clipboard # Wayland 剪贴板工具
    clipse # TUI 粘贴板管理器
  ];

  xdg.configFile."niri/config.kdl" = {
    source = ./niri-config.kdl;
    force = true;
  };

  xdg.configFile."niri/binds.kdl" = {
    source = ./binds.kdl;
    force = true;
  };

  xdg.configFile."niri/noctalia-shell.kdl" = {
    source = ./noctalia-shell.kdl;
    force = true;
  };

  xdg.configFile."niri/animation.kdl" = {
    source = ./animation.kdl;
    force = true;
  };
}
