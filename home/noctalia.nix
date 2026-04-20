{ config, pkgs, lib, ... }:
{
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      general = {
        language = "zh-CN";
      };
      ui = {
        language = "zh-CN";
        fontDefault = "Noto Sans CJK SC";
        fontFixed = "JetBrainsMono Nerd Font";
        fontDefaultScale = 1.1;
        fontFixedScale = 1.1;
      };
      bar = {
        position = "top";
        density = "spacious";
        fontScale = 1.0;
        marginVertical = 12;
        marginHorizontal = 12;
        contentPadding = 6;
        widgets = {
          center = [
            {
              id = "Workspace";
              iconScale = 1.0;
              pillSize = 0.9;
            }
            {
              id = "Taskbar";
              iconScale = 1.0;
            }
          ];
        };
      };
      wallpaper = {
        enabled = true;
        overviewEnabled = true;
        useSolidColor = false;
        directory = "${config.home.homeDirectory}/.config/noctalia/wallpapers";
        viewMode = "crop";
        wallpaperChangeMode = "random";
      };
      colorSchemes = {
        predefinedScheme = "Dracula";
        darkMode = true;
      };
    };
  };

  home.file.".config/noctalia/wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };
}