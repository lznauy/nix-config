{ lib, ... }:
let
  user = import ../../../config/user.nix;
  providers = import ../../../config/ai.nix;
in
{
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    age.keyFile = "${user.home}/.config/sops/age/keys.txt";

    secrets = lib.genAttrs (map (provider: provider.secret) (builtins.attrValues providers)) (_: {
      owner = user.name;
      inherit (user) group;
    });
  };
}
