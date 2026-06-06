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
    ../common/xwayland.nix
    ../common/secrets.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.proxy.default = "http://127.0.0.1:7897/";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # zram swap，内存不足时压缩到内存中，比传统 swap 快
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  virtualisation.docker.enable = true;

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
