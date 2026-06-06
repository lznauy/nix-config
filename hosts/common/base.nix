# 所有主机共享的基础配置
# 任何新 host 都应 import 此文件
{ pkgs, ... }:
{
  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 8;
    cores = 2;
    keep-derivations = true;
    keep-outputs = true;
  };

  # 只保留最近 30 个 generation（systemd-boot 菜单条目）
  boot.loader.systemd-boot.configurationLimit = 30;

  # 定期垃圾回收，删除 7 天前的无用 store 路径
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

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

  system.stateVersion = "26.05";
}
