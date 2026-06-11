{ config, lib, ... }:
{
  systemd.tmpfiles.rules = [
    "d /home/lznauy/.config/reasonix 0755 lznauy users -"
  ];

  sops.templates."reasonix.toml" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.config/reasonix/config.toml";
    content = ''
      default_model = "deepseek-pro"
      language = "zh"

      [[providers]]
      name = "deepseek-flash"
      kind = "openai"
      base_url = "https://api.deepseek.com"
      model = "deepseek-v4-flash"
      api_key_env = "DEEPSEEK_API_KEY"

      [[providers]]
      name = "deepseek-pro"
      kind = "openai"
      base_url = "https://api.deepseek.com"
      model = "deepseek-v4-pro"
      api_key_env = "DEEPSEEK_API_KEY"

      [[providers]]
      name = "mimo-pro"
      kind = "openai"
      base_url = "https://token-plan-cn.xiaomimimo.com/v1"
      model = "mimo-v2.5-pro"
      api_key_env = "MIMO_API_KEY"

      [agent]
      max_steps = 0
      auto_plan = "off"

      [tools]
      bash_timeout_seconds = 120

      [permissions]
      mode = "ask"
    '';
  };

  # reasonix 通过 api_key_env 读取环境变量中的 API key
  sops.templates."reasonix-env.fish" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.config/fish/conf.d/reasonix-env.fish";
    content = ''
      set -gx DEEPSEEK_API_KEY "${config.sops.placeholder."api_keys/deepseek"}"
      set -gx MIMO_API_KEY "${config.sops.placeholder."api_keys/mimo"}"
    '';
  };
}
