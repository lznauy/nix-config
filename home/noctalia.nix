{ config, pkgs, ... }:
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      bar = {
        position = "bottom";
      };
    };
  };
}