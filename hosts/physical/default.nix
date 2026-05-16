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
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  environment.sessionVariables = {
    QS_ICON_THEME = "WhiteSur-dark";
  };

  services.openssh.settings.AllowUsers = [ "lznauy" ];
}
