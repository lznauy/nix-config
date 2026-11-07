# nh - NixOS 辅助管理工具(重建)
# 清理统一交给系统级 nix.gc（见 hosts/common/base.nix）：
# 用户级的 nh clean 删不掉 root 拥有的 system generation 和 gcroots，
# 每次只清几十 MB 还返回成功，已去掉。
_: {
  programs.nh.enable = true;
}
