# VS Code — 微软官方版(含遥测)；想用无遥测的开源构建版把 package 换成 pkgs.vscodium
{pkgs, ...}:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # 微软官方版

    # 扩展在这里加，例如：
    # extensions = with pkgs.vscode-extensions; [
    #   ms-python.python
    #   rust-lang.rust-analyzer
    # ];

    # 用户设置在这里加（会写入 ~/.config/Code/User/settings.json）
    # userSettings = {
    #   "editor.fontSize" = 14;
    # };
  };
}
