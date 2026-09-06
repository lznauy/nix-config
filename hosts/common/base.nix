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
