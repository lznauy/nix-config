{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common/base.nix
    ../common/i18n.nix
    ../common/clash-verge.nix
    ../common/flatpak.nix
    ../common/xwayland.nix
    ../common/secrets
    ./virtualisation.nix
    ./winapps.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.proxy.default = "http://127.0.0.1:7897/";
  # Keep local and libvirt guest traffic away from the global Clash proxy.
  networking.proxy.noProxy = "127.0.0.1,localhost,192.168.122.0/24";
  # Let libvirt guests use the host Clash proxy without exposing it on the LAN.
  networking.firewall.interfaces.virbr0.allowedTCPPorts = [ 7897 ];
  networking.firewall.allowedTCPPorts = [ 7897 ];

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
  virtualisation.docker.enable = true;

  # 指纹识别
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  users.users.lznauy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
      "docker"
    ];
  };

  users.users.lznauy.shell = pkgs.fish;

  programs.fish.enable = true;
  programs.zsh.enable = true;

  programs.niri.enable = true;
  # greetd + tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%Y-%m-%d %H:%M' --remember --remember-session --sessions '${config.services.displayManager.sessionData.desktops}/share/wayland-sessions' --cmd niri-session";
      };
    };
  };

  environment.sessionVariables = {
    QS_ICON_THEME = "WhiteSur-dark";
  };

  services.openssh.settings.AllowUsers = [ "lznauy" ];
}
