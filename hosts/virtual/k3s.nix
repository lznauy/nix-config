# k3s 学习 VM
# 使用: nixos-rebuild build-vm --flake .#vm-k3s
# 运行: ./result/bin/run-k3s-vm
{ pkgs, lib, ... }:
{
  imports = [
    ../common/base.nix
    ./base.nix
  ];

  networking.hostName = "k3s";

  users.users.root.initialPassword = "admin@123";
  users.users.lznauy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "admin@123";
  };

  # VM 磁盘和引导（build-vm 会自动覆盖为虚拟磁盘）
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  boot.loader.grub.devices = [ "/dev/vda" ];
  boot.loader.timeout = 0;

  # k3s 单节点集群
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--write-kubeconfig-mode 644 --disable traefik";
  };

  # 防火墙放行
  networking.firewall.allowedTCPPorts = [ 6443 80 443 22 ];

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.AllowUsers = lib.mkForce [ "root" "lznauy" ];

  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubernetes-helm
  ];

  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  # containerd 镜像加速（国内网络）
  environment.etc."rancher/k3s/registries.yaml".text = ''
    mirrors:
      docker.io:
        endpoint:
          - "https://docker.1ms.run"
          - "https://docker.xuanyuan.me"
      ghcr.io:
        endpoint:
          - "https://ghcr.1ms.run"
  '';

  # VM 资源配置
  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 2;
    diskSize = 20480;  # 20GB
    forwardPorts = [
      { from = "host"; host.port = 6443; guest.port = 6443; }  # k8s API
      { from = "host"; host.port = 8080; guest.port = 80; }    # HTTP
      { from = "host"; host.port = 2222; guest.port = 22; }    # SSH
    ];
  };
}
