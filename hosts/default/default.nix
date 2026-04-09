{ config, lib, pkgs, ... }:

{
  imports = [];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;

  time.timeZone = "Asia/Shanghai";

  users.users.lznauy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "users" "networkmanager" "docker" ];
  };
  users.users.lznauy.shell = pkgs.zsh;

  programs.zsh.enable = true;
  
  # Niri
  programs.niri.enable = true;
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.AllowUsers = [ "lznauy" ];

  system.stateVersion = "26.05";
}
