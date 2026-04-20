{ config, lib, pkgs, ... }:

{
  imports = [
    ./i18n.nix
    ./clash-verge.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.proxy.default = "http://192.168.1.142:7897/";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;

  users.users.lznauy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "users" "networkmanager" "docker" ];
  };

  # users.users.lznauy.shell = pkgs.zsh;
  users.users.lznauy.shell = pkgs.fish;

  # programs.zsh.enable = true;
  programs.fish.enable = true;

  programs.niri.enable = true;
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  environment.sessionVariables = {
    QS_ICON_THEME = "WhiteSur-dark";
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    curl
    htop
    vim
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.AllowUsers = [ "lznauy" ];

  system.stateVersion = "26.05";
}
