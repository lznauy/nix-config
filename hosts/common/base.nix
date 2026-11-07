# 所有主机共享的基础配置
# 任何新 host 都应 import 此文件
{ lib, pkgs, ... }:
{
  imports = [ ./locale.nix ];

  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Hosts can override the shared build budget with ordinary assignments.
    max-jobs = lib.mkDefault 8;
    cores = lib.mkDefault 2;
    keep-derivations = true;
    keep-outputs = true;
    # 可用空间低于 20G 时让 nix 自动触发 GC，腾到 50G 为止。
    min-free = 20 * 1024 * 1024 * 1024;
    max-free = 50 * 1024 * 1024 * 1024;
  };

  # 定期垃圾回收。必须走系统级 nix-gc.timer（root 权限），
  # 用户级的 nh clean 删不掉 root 拥有的 system generation，等于白跑。
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    curl
    htop
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
