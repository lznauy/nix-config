{ pkgs, ... }:

{
  programs.xwayland = {
    enable = true;
    # 将编译期字体路径改为运行时参数，保留 core X fonts 并复用原版缓存。
    package = pkgs.symlinkJoin {
      name = "xwayland-with-font-path";
      paths = [ pkgs.xwayland ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/Xwayland \
          --add-flags "-fp /run/current-system/sw/share/X11/fonts"
      '';
    };
  };
  services.xserver.enable = true;

  environment.systemPackages = [
    pkgs.xwayland-satellite # XWayland 兼容层桥接器
  ];
}
