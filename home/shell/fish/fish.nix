{ config, pkgs, ... }:

{
  home.packages = [ pkgs.starship ];

  home.file.".config/starship.toml".source = ./starship.toml;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };
}