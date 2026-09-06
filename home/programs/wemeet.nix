{ pkgs, ... }:
{
  home.packages = [ pkgs.wemeet ];
  xdg.desktopEntries."wemeetapp" = {
    name = "腾讯会议";
    comment = "腾讯会议 Linux 版";
    exec = "wemeet-xwayland %u";
    icon = "wemeet";
    type = "Application";
    terminal = false;
    categories = [
      "AudioVideo"
      "Network"
    ];
    mimeType = [ "x-scheme-handler/wemeet" ];
    settings.StartupWMClass = "wemeetapp";
  };
}
