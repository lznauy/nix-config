{
  config,
  pkgs,
  lib,
  ...
}:

let
  iconThemeName = "WhiteSur-dark";
  gtkThemeName = "WhiteSur-Dark";
in
{
  gtk = {
    enable = true;
    theme = {
      name = gtkThemeName;
      package = pkgs.whitesur-gtk-theme;
    };
    iconTheme = {
      name = iconThemeName;
      package = pkgs.whitesur-icon-theme;
    };
  };

  gtk.gtk3 = {
    enable = lib.mkDefault true;
  };

  gtk.gtk4 = {
    enable = lib.mkDefault true;
  };

  home.sessionVariables = {
    XDG_ICON_THEME = iconThemeName;
    QT_QPA_PLATFORMTHEME = "gtk3";
    QS_ICON_THEME = iconThemeName;
  };

  home.packages = with pkgs; [
    whitesur-icon-theme # macOS 风格图标主题
    hicolor-icon-theme # 标准回退图标主题
    papirus-icon-theme # Papirus 图标主题
  ];
}
