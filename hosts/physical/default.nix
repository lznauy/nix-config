_:
let
  user = import ../../config/user.nix;
in
{
  imports = [
    ../../profiles/desktop.nix
    ./virtualisation.nix
    ./winapps.nix
  ];

  networking.hostName = "nixos";
  networking.proxy.default = "http://127.0.0.1:7897/";
  # Keep local and libvirt guest traffic away from the global Clash proxy.
  networking.proxy.noProxy = "127.0.0.1,localhost,192.168.122.0/24";
  # libvirt guests and the VMware desktop both use this proxy.
  # VMware connects over the LAN (see hosts/vmware/default.nix), not virbr0.
  networking.firewall.allowedTCPPorts = [ 7897 ];
  networking.firewall.interfaces.virbr0.allowedTCPPorts = [ 7897 ];

  home-manager.users.${user.name} = {
    home.sessionVariables = {
      QS_TRANSLATOR_MODEL_DIR = "${user.home}/live-translator/models";
      QS_TRANSLATOR_BIN = "${user.home}/live-translator/target/release/live-translator";
      QS_TRANSLATOR_AUDIO_DEVICE = "pw:alsa_output.pci-0000_03_00.6.HiFi__Speaker__sink";
    };
    xdg.configFile."niri/outputs.kdl".text = ''
      // This monitor advertises an incorrect preferred mode through EDID.
      output "HDMI-A-1" {
        mode "1920x1080@60.000"
        scale 1
      }
    '';
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # zram swap，内存不足时压缩到内存中，比传统 swap 快
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 100;
  };

  # Keep zram as the fast first tier, then spill cold pages to NVMe instead of
  # letting the host lock up when the Windows VM creates sustained pressure.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      priority = -10;
    }
  ];

  systemd.oomd.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # 指纹识别
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

}
