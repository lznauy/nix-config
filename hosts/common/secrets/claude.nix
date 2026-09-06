{ config, lib, ... }:
let
  user = import ../../../config/user.nix;
  providers = import ../../../config/ai.nix;
in
{
  systemd.tmpfiles.rules = [ "d ${user.home}/.claude 0700 ${user.name} ${user.group} -" ];
  sops.templates = lib.mapAttrs' (
    name: provider:
    lib.nameValuePair "claude-settings-${name}.json" {
      owner = user.name;
      inherit (user) group;
      path = "${user.home}/.claude/settings-${name}.json";
      content = builtins.toJSON {
        env = {
          ANTHROPIC_BASE_URL = provider.anthropicURL;
          ANTHROPIC_AUTH_TOKEN = config.sops.placeholder.${provider.secret};
          ANTHROPIC_MODEL = provider.claudeModel;
          ANTHROPIC_DEFAULT_OPUS_MODEL = provider.claudeModel;
          ANTHROPIC_DEFAULT_SONNET_MODEL = provider.claudeModel;
          ANTHROPIC_DEFAULT_HAIKU_MODEL = provider.fastModel;
          CLAUDE_CODE_SUBAGENT_MODEL = provider.fastModel;
          CLAUDE_CODE_EFFORT_LEVEL = "max";
        };
      };
    }
  ) providers;
}
