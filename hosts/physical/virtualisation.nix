{ pkgs, ... }:

{
  programs.virt-manager = {
    enable = true;
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
