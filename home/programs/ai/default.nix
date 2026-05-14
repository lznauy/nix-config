{ pkgs, ... }:

let
  inherit (import ./skills { inherit pkgs; }) all-skills all-rules all-context;
in
{
  # Claude Code 配置路径为 ~/.claude/（模块硬编码，无法改为 XDG 路径）
  # skills/rules/context 由模块自动写入 ~/.claude/
  programs.claude-code = {
    enable = true;
    skills = all-skills;
    rules = all-rules;
    context = all-context;
  };

  # OpenCode 配置路径为 ~/.config/opencode/（标准 XDG）
  programs.opencode = {
    enable = true;
    skills = all-skills;
    context = all-context;
  };

  home.sessionVariables.CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";

  home.packages = with pkgs; [
    mcp-nixos
  ];
}
