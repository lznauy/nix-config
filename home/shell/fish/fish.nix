{ config, pkgs, ... }:

{
  home.packages = [ pkgs.starship ]; # 跨 shell 美化提示符

  xdg.configFile."starship.toml" = {
    source = ./starship.toml;
    force = true;
  };

  programs.fish = {
    enable = true;
    shellInit = "set -x TERM xterm-256color";
    interactiveShellInit = ''
      set fish_greeting
    '';
    functions = {
      claude-ds = {
        body = "command claude --settings ~/.claude/settings-deepseek.json $argv";
      };
      claude-mimo = {
        body = "command claude --settings ~/.claude/settings-mimo.json $argv";
      };
      opencode = {
        body = "command opencode -m deepseek/deepseek-v4-pro $argv";
      };
      opencode-mimo = {
        body = "command opencode -m mimo/mimo-v2.5-pro $argv";
      };
    };
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };
}
