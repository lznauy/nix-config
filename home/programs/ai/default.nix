{ pkgs, inputs, ... }:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.sessionVariables.CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";

  home.packages = [
    pkgs.mcp-nixos
    llm-agents.omp
    llm-agents.reasonix
    llm-agents.cc-switch-cli
  ];
}
