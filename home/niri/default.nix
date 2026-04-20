{ config, pkgs, ... }: {
  xdg.configFile."niri/config.kdl" = {
    source = ./niri-config.kdl;
    force = true;
  };

  xdg.configFile."niri/binds.kdl" = {
    source = ./binds.kdl;
    force = true;
  };

  xdg.configFile."niri/noctalia-shell.kdl" = {
    source = ./noctalia-shell.kdl;
    force = true;
  };
}