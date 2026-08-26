{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ ./deepseek-harness.nix ];

  home.sessionVariables.CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";

  programs.claude-code = {
    enable = true;
  };

  # OpenCode 配置路径为 ~/.config/opencode/（标准 XDG）
  programs.opencode = {
    enable = true;
  };

  # Codex 配置路径为 ~/.codex/
  # 使用 llm-agents 的包（nixpkgs 官方源更新太慢）
  programs.codex = {
    enable = true;
    package = llm-agents.codex;
  };

  home.packages = [
    pkgs.mcp-nixos
    pkgs.pyright
    llm-agents.open-code-review
    llm-agents.freebuff
    llm-agents.omp
    llm-agents.reasonix
    llm-agents.cc-switch-cli
    llm-agents.hermes-agent
    llm-agents.kimi-code
  ];
}
