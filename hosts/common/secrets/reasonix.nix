{ config, ... }:
let
  user = import ../../../config/user.nix;
  providers = import ../../../config/ai.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${user.home}/.config/reasonix 0755 ${user.name} ${user.group} -"
  ];

  sops.templates."reasonix.toml" = {
    owner = user.name;
    inherit (user) group;
    path = "${user.home}/.config/reasonix/config.toml";
    content = ''
      default_model = "deepseek-pro"
      language = "zh"

      [[providers]]
      name = "deepseek-flash"
      kind = "openai"
      base_url = "${providers.deepseek.origin}"
      model = "${providers.deepseek.fastModel}"
      api_key_env = "DEEPSEEK_API_KEY"

      [[providers]]
      name = "deepseek-pro"
      kind = "openai"
      base_url = "${providers.deepseek.origin}"
      model = "${providers.deepseek.model}"
      api_key_env = "DEEPSEEK_API_KEY"

      [[providers]]
      name = "mimo-pro"
      kind = "openai"
      base_url = "${providers.mimo.baseURL}"
      model = "${providers.mimo.model}"
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
    owner = user.name;
    inherit (user) group;
    path = "${user.home}/.config/fish/conf.d/reasonix-env.fish";
    content = ''
      set -gx DEEPSEEK_API_KEY "${config.sops.placeholder."api_keys/deepseek"}"
      set -gx MIMO_API_KEY "${config.sops.placeholder."api_keys/mimo"}"
    '';
  };
}
