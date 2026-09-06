{ pkgs, ... }:
{
  home.packages = [ pkgs.blueman ];
  xdg.desktopEntries."blueman-adapters" = {
    name = "蓝牙适配器";
    comment = "设置蓝牙适配器属性";
    exec = "blueman-adapters";
    icon = "preferences-system-bluetooth";
    terminal = false;
    type = "Application";
    categories = [
      "Settings"
      "HardwareSettings"
      "GTK"
    ];
    startupNotify = true;
  };
  xdg.configFile."autostart/blueman-applet.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=blueman-applet
    Exec=${pkgs.blueman}/bin/blueman-applet
    Icon=blueman
    Terminal=false
    StartupNotify=false
  '';
}
