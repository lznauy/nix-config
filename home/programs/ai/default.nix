{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.sessionVariables.CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";

  programs.claude-code = {
    enable = true;
  };

  # OpenCode 配置路径为 ~/.config/opencode/（标准 XDG）
  programs.opencode = {
    enable = true;
  };

  # Codex 配置路径为 ~/.codex/
  programs.codex = {
    enable = true;
  };

  home.packages = [
    pkgs.mcp-nixos
    llm-agents.omp
    llm-agents.reasonix
    llm-agents.cc-switch-cli
    llm-agents.hermes-agent
  ];
}
