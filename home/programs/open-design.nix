{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zenity # open-design会调用的文件管理器
  ];

  services.open-design = {
    enable = true;
    autoStart = true;
    # Web 前端由 Caddy 提供，访问 http://127.0.0.1:5174/；7457 是 daemon API 端口。
    webFrontend.enable = true;
  };
}
