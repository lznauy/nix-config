{ config, pkgs, ... }:

let
  p10k-theme = pkgs.zsh-powerlevel10k;
in
{
  home.packages = [ p10k-theme ];

  home.shell.enableZshIntegration = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  home.file.".p10k.zsh".source = ./shell/zsh/p10k.zsh;
}
