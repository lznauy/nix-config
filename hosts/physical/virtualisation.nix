{ pkgs, ... }:

let
  # niri 全局 prefer-no-csd 会让 GTK 应用不画标题栏；强制 virt-manager 用 CSD 恢复关闭按钮
  virt-manager-csd = pkgs.symlinkJoin {
    name = "virt-manager-csd";
    paths = [ pkgs.virt-manager ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/virt-manager --set GTK_CSD 1
    '';
  };
in
{
  programs.virt-manager = {
    enable = true;
    package = virt-manager-csd;
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  # qcow2 already provides copy-on-write; disable the outer Btrfs CoW layer for
  # newly created VM images to reduce fragmentation and write amplification.
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0711 root root -"
    "h /var/lib/libvirt/images - - - - +C"
  ];

  environment.systemPackages = [ pkgs.virt-viewer ];

  users.users.lznauy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
