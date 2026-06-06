# nh - NixOS 辅助管理工具(重建/清理)
{ config, pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      # 启用清理
      enable = true;
      # 清理操作的执行频率
      dates = "weekly";
      # 清理参数
      extraArgs = "--keep 20 --keep-since 7d";
    };
  };
}
