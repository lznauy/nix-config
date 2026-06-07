{ config, lib, ... }:
{
  # 确保 ~/.omp/agent 目录存在（在 sops templates 写入前创建）
  system.activationScripts.omp-config-dir = lib.mkBefore ''
    mkdir -p /home/lznauy/.omp/agent
    chown lznauy:users /home/lznauy/.omp/agent
  '';

  sops.templates."omp-models.yml" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.omp/agent/models.yml";
    content = ''
providers:
  deepseek:
    baseUrl: https://api.deepseek.com/v1
    apiKey: ${config.sops.placeholder."api_keys/deepseek"}
    api: openai-completions
    models:
      - id: deepseek-v4-pro
        name: DeepSeek V4 Pro
        reasoning: false
        input:
          - text
        contextWindow: 256000
        maxTokens: 4096
      - id: deepseek-v4-flash
        name: DeepSeek V4 Flash
        reasoning: false
        input:
          - text
        contextWindow: 256000
        maxTokens: 4096
  mimo:
    baseUrl: https://token-plan-cn.xiaomimimo.com/v1
    apiKey: ${config.sops.placeholder."api_keys/mimo"}
    api: openai-completions
    models:
      - id: mimo-v2.5-pro
        name: MiMo V2.5 Pro
        reasoning: false
        input:
          - text
          - image
        contextWindow: 200000
        maxTokens: 4096
    '';
  };
}
