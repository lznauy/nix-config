# Shared provider facts; each client keeps its own protocol adapter.
{
  deepseek = {
    name = "DeepSeek";
    baseURL = "https://api.deepseek.com/v1";
    anthropicURL = "https://api.deepseek.com/anthropic";
    origin = "https://api.deepseek.com";
    secret = "api_keys/deepseek";
    model = "deepseek-v4-pro";
    fastModel = "deepseek-v4-flash";
    claudeModel = "deepseek-v4-pro[1m]";
    context = 256000;
    output = 4096;
    input = [ "text" ];
  };
  mimo = {
    name = "MiMo";
    baseURL = "https://token-plan-cn.xiaomimimo.com/v1";
    anthropicURL = "https://token-plan-cn.xiaomimimo.com/anthropic";
    secret = "api_keys/mimo";
    model = "mimo-v2.5-pro";
    fastModel = "mimo-v2.5-pro";
    claudeModel = "mimo-v2.5-pro";
    context = 200000;
    output = 4096;
    input = [
      "text"
      "image"
    ];
  };
}
