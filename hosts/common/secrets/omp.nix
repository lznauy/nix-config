{ config, lib, ... }:
let
  user = import ../../../config/user.nix;
  providers = import ../../../config/ai.nix;
in
{
  systemd.tmpfiles.rules = [ "d ${user.home}/.omp/agent 0700 ${user.name} ${user.group} -" ];
  sops.templates."omp-models.yml" = {
    owner = user.name;
    inherit (user) group;
    path = "${user.home}/.omp/agent/models.yml";
    # JSON is a YAML subset, so values are escaped without hand-written YAML.
    content = builtins.toJSON {
      providers = lib.mapAttrs (_: provider: {
        baseUrl = provider.baseURL;
        apiKey = config.sops.placeholder.${provider.secret};
        api = "openai-completions";
        models =
          map
            (model: {
              id = model;
              name = model;
              reasoning = false;
              inherit (provider) input;
              contextWindow = provider.context;
              maxTokens = provider.output;
            })
            (
              lib.unique [
                provider.model
                provider.fastModel
              ]
            );
      }) providers;
    };
  };
}
