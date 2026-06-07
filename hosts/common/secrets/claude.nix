{ config, lib, ... }:
{
  # 确保 ~/.claude 目录存在（在 sops templates 写入前创建）
  system.activationScripts.claude-config-dir = lib.mkBefore ''
    mkdir -p /home/lznauy/.claude
    chown lznauy:users /home/lznauy/.claude
  '';

  sops.templates."claude-settings-deepseek.json" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.claude/settings-deepseek.json";
    content = builtins.toJSON {
      env = {
        ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
        ANTHROPIC_AUTH_TOKEN = config.sops.placeholder."api_keys/deepseek";
        ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
        CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash";
        CLAUDE_CODE_EFFORT_LEVEL = "max";
      };
    };
  };

  sops.templates."claude-settings-mimo.json" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.claude/settings-mimo.json";
    content = builtins.toJSON {
      env = {
        ANTHROPIC_BASE_URL = "https://token-plan-cn.xiaomimimo.com/anthropic";
        ANTHROPIC_AUTH_TOKEN = config.sops.placeholder."api_keys/mimo";
        ANTHROPIC_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "mimo-v2.5-pro";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "mimo-v2.5-pro";
        CLAUDE_CODE_SUBAGENT_MODEL = "mimo-v2.5-pro";
        CLAUDE_CODE_EFFORT_LEVEL = "max";
      };
    };
  };
}
