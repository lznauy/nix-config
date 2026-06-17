{ pkgs, ... }:
let
  colorScheme = rec {
    custom = true;
    name = "midnight";
    path =
      if custom then
        ./colorschemes/${name}.yaml
      else
        "${pkgs.base16-schemes}/share/themes/${name}.yaml";
    polarity = "dark";
  };
in
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    autoEnable = false; # 选择性启用主题，只对明确配置的目标生效
    base16Scheme = colorScheme.path;
    polarity = colorScheme.polarity;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 13;
        desktop = 13;
        popups = 13;
        terminal = 13;
      };
    };

    targets = {
      nixvim.enable = true;
    };
  };
}
