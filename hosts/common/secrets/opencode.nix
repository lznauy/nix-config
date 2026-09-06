{ config, lib, ... }:
let
  user = import ../../../config/user.nix;
  providers = import ../../../config/ai.nix;
  mkModel = provider: model: {
    name = model;
    limit = {
      inherit (provider) context;
      inherit (provider) output;
    };
    modalities = {
      inherit (provider) input;
      output = [ "text" ];
    };
  };
in
{
  systemd.tmpfiles.rules = [ "d ${user.home}/.config/opencode 0700 ${user.name} ${user.group} -" ];
  sops.templates."opencode.json" = {
    owner = user.name;
    inherit (user) group;
    path = "${user.home}/.config/opencode/config.json";
    content = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "deepseek/${providers.deepseek.model}";
      mcp.nixos = {
        type = "local";
        command = [ "mcp-nixos" ];
        enabled = true;
      };
      provider = lib.mapAttrs (_: provider: {
        npm = "@ai-sdk/openai-compatible";
        inherit (provider) name;
        options = {
          inherit (provider) baseURL;
          apiKey = config.sops.placeholder.${provider.secret};
        };
        models = lib.genAttrs (lib.unique [
          provider.model
          provider.fastModel
        ]) (mkModel provider);
      }) providers;
    };
  };
}
