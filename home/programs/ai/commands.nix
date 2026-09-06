_:
let
  providers = import ../../../config/ai.nix;
in
{
  programs.fish.functions = {
    claude-ds = {
      body = "command claude --settings ~/.claude/settings-deepseek.json $argv";
    };
    claude-mimo = {
      body = "command claude --settings ~/.claude/settings-mimo.json $argv";
    };
    opencode = {
      body = "command opencode -m deepseek/${providers.deepseek.model} $argv";
    };
    opencode-mimo = {
      body = "command opencode -m mimo/${providers.mimo.model} $argv";
    };
  };
}
