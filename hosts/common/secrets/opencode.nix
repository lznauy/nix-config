{ config, lib, ... }:
{
  # 确保 ~/.config/opencode 目录存在（在 sops templates 写入前创建）
  system.activationScripts.opencode-config-dir = lib.mkBefore ''
    mkdir -p /home/lznauy/.config/opencode
    chown lznauy:users /home/lznauy/.config/opencode
  '';

  sops.templates."opencode.json" = {
    owner = "lznauy";
    group = "users";
    path = "/home/lznauy/.config/opencode/config.json";
    content = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "deepseek/deepseek-v4-pro";
      mcp = {
        nixos = {
          type = "local";
          command = [ "mcp-nixos" ];
          enabled = true;
        };
      };
      provider = {
        deepseek = {
          npm = "@ai-sdk/openai-compatible";
          name = "DeepSeek";
          options = {
            baseURL = "https://api.deepseek.com/v1";
            apiKey = config.sops.placeholder."api_keys/deepseek";
          };
          models = {
            "deepseek-v4-pro" = {
              name = "deepseek-v4-pro";
              limit = {
                context = 256000;
                output = 4096;
              };
              modalities = {
                input = [ "text" ];
                output = [ "text" ];
              };
            };
            "deepseek-v4-flash" = {
              name = "deepseek-v4-flash";
              limit = {
                context = 256000;
                output = 4096;
              };
              modalities = {
                input = [ "text" ];
                output = [ "text" ];
              };
            };
          };
        };
        mimo = {
          npm = "@ai-sdk/openai-compatible";
          name = "MIMO";
          options = {
            baseURL = "https://token-plan-cn.xiaomimimo.com/v1";
            apiKey = config.sops.placeholder."api_keys/mimo";
          };
          models = {
            "mimo-v2.5-pro" = {
              name = "mimo-v2.5-pro";
              limit = {
                context = 200000;
                output = 4096;
              };
              modalities = {
                input = [ "text" "image" ];
                output = [ "text" ];
              };
            };
          };
        };
      };
    };
  };
}
