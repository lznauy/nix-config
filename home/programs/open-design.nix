{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zenity # open-design会调用的文件管理器
  ];

  services.open-design = {
    enable = true;
    autoStart = true;
    webFrontend.enable = true;
  };
}
